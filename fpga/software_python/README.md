# IACQ - FPGA Communication Library 

## Overview
Ce projet fournit une interface Python robuste (`IACQ`) pour communiquer avec un FPGA (ou son émulateur logiciel) via le protocole UART. Il est conçu pour envoyer des signaux ECG bruts au FPGA afin de les chiffrer en toute sécurité à l'aide de l'algorithme ASCON-128. 

## Installation
Les seules bibliothèques nécessaires sont `pyserial` (pour la communication matérielle) et `matplotlib` (pour tracer les données).

```bash
pip install pyserial matplotlib
```
##  Analyse Biomédicale Avancée en Temps Réel

Ce projet implémente plusieurs fonctionnalités d'analyse biomédicale opérant directement sur le flux de données déchiffrées.

---

### Diagramme de Poincaré (HRV)

Un sous-graphique dédié affiche un nuage de points traçant l'intervalle $RR_i$ en fonction de $RR_{i+1}$.

- **Objectif** : Évaluer visuellement la variabilité de la fréquence cardiaque (HRV).
- **Intérêt clinique** : Permet de détecter les battements ectopiques et d'identifier des patterns de dysrégulation autonome.

---

###  Mesure de l'Intervalle QT

Délimitation automatique des ondes **Q** et **T** pour calculer l'intervalle QT en millisecondes.

- **Indicateur** : Marqueur critique de la repolarisation ventriculaire.
- **Usage** : Surveillance des risques d'arythmies fatales (ex. torsades de pointes).

---

### Dépistage Étendu des Arythmies

Le système signale automatiquement les anomalies cardiaques suivantes :

| Condition détectée         | Critère de détection                          |
|---------------------------|----------------------------------------------- |
| **Tachycardie**           | Fréquence cardiaque > 110 bpm                  |
| **Bradycardie**           | Fréquence cardiaque < 50 bpm                   |
| **Suspicion d'arythmie**  | Variance élevée du HRV (SDNN)                  |
| **Syndrome du QT long**   | Intervalle QT corrigé > 450 ms                 |

> **Note** : Les alertes sont générées en temps réel et horodatées sur le flux de données déchiffrées.

### Quick Start
Voici un exemple minimal pour envoyer une clé secrète au FPGA. Copiez-collez ce code pour tester rapidement la bibliothèque :

```Python
from iacq import IACQ

# Le bloc 'with' garantit la fermeture propre de la connexion
with IACQ(port="COM3", emulator=False) as fpga: #Remplacer COM3 par le vrai port
    cle_secrete = b"0123456789ABCDEF"
    
    # Envoi sécurisé (vérifie que la clé fait bien 16 octets)
    fpga.send_key(cle_secrete)
    
    print(f"Réponse du FPGA : {fpga.read_response()}")
``` 
API Reference
Voici les méthodes principales disponibles dans la classe `IACQ`:

`open()` : Ouvre la connexion (série ou émulateur).

`close()` : Ferme proprement la connexion et libère le port.

`send_key(key: bytes)` : Valide et envoie la clé de chiffrement (16 octets).

`send_nonce(nonce: bytes)` : Valide et envoie le nonce (16 octets).

`send_associated_data(ad: bytes)` : Valide et envoie les données associées (maximum 8 octets).

`send_waveform(waveform: bytes)` : Valide et envoie le signal ECG (181 octets).

`read_response() -> bytes` : Lit la réponse du FPGA.

Hardware vs Emulator Usage
La classe permet de basculer facilement entre la vraie carte et l'émulateur.

Mode Émulateur:

```Python
fpga = IACQ(port="VIRTUAL", emulator=True) 
```
Mode Matériel:

```Python
# Remplacer COM3 par le vrai port (ex: /dev/ttyUSB0 sous Linux)
fpga = IACQ(port="COM3", baud_rate=115200, timeout=3, emulator=False)
```

Troubleshooting (Dépannage)
Access is denied ou Port is already open : Le port série est monopolisé par un autre programme (PuTTY) ou est resté ouvert. Débranchez/rebranchez le câble USB.

Timeout (Aucune réponse du FPGA) : Le FPGA n'a pas eu le temps de s'initialiser. Ajoutez import time et un time.sleep(2) juste après l'ouverture de la connexion.

FPGAValidationError : Vos données d'entrée sont incorrectes. Vérifiez le type (bytes) et la longueur (ex: 16 octets pour la clé).
