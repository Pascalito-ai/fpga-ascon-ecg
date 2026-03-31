import hashlib
import time
import numpy as np
import neurokit2 as nk
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from collections import deque

from iacq import IACQ

KEY = bytes.fromhex("8A55114D1CB6A9A2BE263D4D7AECAAFF")
NONCE = bytes.fromhex("4ED0EC0B98C529B7C8CDDF37BCD0284A")
AD = b"A to B"

def afficher_hashes_bitstream():
    print("="*50)
    print(" VERIFICATION DE L'AUTHENTICITE DU BITSTREAM")
    print("="*50)
    
    fichiers_a_verifier = {
        "Bitstream donné": "IACQ.bit/IACQ.bit", 
        "Notre Bitstream": "Ascon_top.bit"
    }

    for nom, chemin in fichiers_a_verifier.items():
        try:
            with open(chemin, "rb") as f:
                sha256_hash = hashlib.sha256()
                while chunk := f.read(8192):
                    sha256_hash.update(chunk)
                empreinte = sha256_hash.hexdigest()
                print(f"{nom} :")
                print(f" -> {empreinte}\n")
        except FileNotFoundError:
            print(f"{nom} :")
            print(f" -> Fichier introuvable ({chemin})\n")
    print("="*50)
    time.sleep(10) 

def precharger_donnees(fichier_csv):
    with open(fichier_csv, 'r') as f:
        return [ligne.strip() for ligne in f.readlines() if ligne.strip()]

lignes_hex_global = precharger_donnees('xNorm.csv')

def load_waveform_from_csv(frame_index):
    ligne_hex = lignes_hex_global[frame_index % len(lignes_hex_global)]
    return bytes.fromhex(ligne_hex)

buffer = deque(maxlen=1800)
rr_history = deque(maxlen=100)
fig, (ax, ax_poin) = plt.subplots(1, 2, figsize=(15, 6), gridspec_kw={'width_ratios': [3, 1]})

line, = ax.plot([], [], lw=1.5, color='blue', label='Signal ECG')
r_scatter, = ax.plot([], [], 'ro', markersize=6, label='Pic R')
p_scatter, = ax.plot([], [], 'go', markersize=4, label='Onde P')
t_scatter, = ax.plot([], [], 'mo', markersize=4, label='Onde T')

info_text = ax.text(0.02, 0.95, "Démarrage du pipeline...", transform=ax.transAxes, 
                    fontsize=10, verticalalignment='top', 
                    bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))

ax.set_title("Live Demo : Pipeline Complet (Chiffrement ASCON + Analyse ECG)")
ax.set_xlim(0, 1800)
ax.set_ylim(-150, 150)
ax.grid(True, linestyle='--', alpha=0.7)
plt.legend(loc='upper right')

poincare_scatter, = ax_poin.plot([], [], 'bo', markersize=4, alpha=0.6)
ax_poin.set_title("Poincaré (HRV)")
ax_poin.set_xlabel("RR_i (ms)")
ax_poin.set_ylabel("RR_{i+1} (ms)")
ax_poin.set_xlim(400, 1200)
ax_poin.set_ylim(400, 1200)
ax_poin.grid(True, linestyle=':', alpha=0.5)
ax_poin.plot([0, 2000], [0, 2000], 'k--', alpha=0.3)

def main():
    afficher_hashes_bitstream()
    
    with IACQ(port="COM9", emulator=False) as fpga:
        
        def update(frame):
            try:
                waveform = load_waveform_from_csv(frame)
                
                ciphertext, tag = fpga.encrypt_on_fpga(waveform, KEY, NONCE, AD)
                
                decrypted = fpga.decrypt_waveform(ciphertext, tag, KEY, NONCE, AD)
                
                buffer.extend(list(decrypted))
                
                if len(buffer) == 1800:
                    sig = np.array(buffer)
                    ecg_cleaned = nk.ecg_clean(sig, sampling_rate=360)
                    _, peaks_info = nk.ecg_peaks(ecg_cleaned, sampling_rate=360)
                    rpeaks = peaks_info["ECG_R_Peaks"]
                    
                    _, waves = nk.ecg_delineate(ecg_cleaned, rpeaks, sampling_rate=360, method="dwt")

                    if len(rpeaks) > 1:
                        rr_intervals = np.diff(rpeaks) / 360 * 1000
                        hr = 60000 / np.mean(rr_intervals)
                        sdnn = np.std(rr_intervals)
                        rmssd = np.sqrt(np.mean(np.diff(rr_intervals)**2))
                        rr_history.extend(rr_intervals)
                        if len(rr_history) > 1:
                            rr_list = list(rr_history)
                            rr_i = rr_list[:-1]
                            rr_i_plus_1 = rr_list[1:]
                            poincare_scatter.set_data(rr_i, rr_i_plus_1)
                        pnn50 = 100 * np.sum(np.abs(np.diff(rr_intervals)) > 50) / len(rr_intervals)
                        
                        qt_interval_str = "N/A"
                        qt_ms = 0
                        q_peaks = [p for p in waves.get('ECG_Q_Peaks', []) if not np.isnan(p)]
                        t_offsets = [t for t in waves.get('ECG_T_Offsets', []) if not np.isnan(t)]
                        
                        if len(q_peaks) > 0 and len(t_offsets) > 0:
                            for q in q_peaks:
                                valid_t = [t for t in t_offsets if t > q]
                                if valid_t:
                                    qt_samples = valid_t[0] - q
                                    qt_ms = (qt_samples / 360) * 1000
                                    
                                    # Calcul du QTc (Formule de Bazett)
                                    rr_sec = np.mean(rr_intervals) / 1000
                                    qtc_ms = qt_ms / np.sqrt(rr_sec)
                                    
                                    qt_interval_str = f"QT: {qt_ms:.0f}ms | QTc: {qtc_ms:.0f}ms"
                                    break

                        anomaly = "Normal"
                        if hr < 50: anomaly = " BRADYCARDIE!"
                        elif hr > 110: anomaly = " TACHYCARDIE!"
                        elif sdnn > 150: anomaly = " ARYTHMIE!"
                        elif qtc_ms > 450: anomaly = " SYNDROME DU QT LONG!"

                        line.set_data(range(len(ecg_cleaned)), ecg_cleaned)
                        r_scatter.set_data(rpeaks, ecg_cleaned[rpeaks])
                        
                        p_peaks = [int(p) for p in waves.get('ECG_P_Peaks', []) if not np.isnan(p)]
                        t_peaks = [int(t) for t in waves.get('ECG_T_Peaks', []) if not np.isnan(t)]
                        p_scatter.set_data(p_peaks, ecg_cleaned[p_peaks])
                        t_scatter.set_data(t_peaks, ecg_cleaned[t_peaks])
                        
                        stats = (f"Rythme: {hr:.1f} BPM\n"
                                 f"SDNN: {sdnn:.1f} ms | RMSSD: {rmssd:.1f} ms\n"
                                 f"pNN50: {pnn50:.1f}%\n"
                                 f"Statut: {anomaly}")
                        info_text.set_text(stats)
                        
                        if "!" in anomaly:
                            info_text.set_bbox(dict(boxstyle='round', facecolor='mistyrose', alpha=0.9))
                        else:
                            info_text.set_bbox(dict(boxstyle='round', facecolor='honeydew', alpha=0.9))

                return line, r_scatter, p_scatter, t_scatter, info_text
                
            except Exception as e:
                print(f"Erreur frame {frame}: {e}")
                return line,

        ani = FuncAnimation(fig, update, frames=range(100000), interval=100, blit=False)
        plt.tight_layout()
        plt.show()

if __name__ == "__main__":
    main()