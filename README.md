# Guide de Démarrage : Chiffrement ECG via FPGA (ASCON-128)
 
**Auteurs :** Mickael GARDES — Mamadou DIALLO
 
---
 
## 1. Présentation du projet
 
Ce projet a pour but de sécuriser l'acquisition et la transmission de données médicales.
 
Dans cette architecture, les signaux ECG sont traités directement au niveau du FPGA (Pynq-Z2 de Xilinx), qui embarque un cœur de chiffrement matériel **ASCON-128**. Une fois les données chiffrées de manière sécurisée par le FPGA, elles sont envoyées via une liaison **UART** vers un ordinateur. Le PC se charge alors de déchiffrer les trames et d'effectuer l'analyse physiologique et la visualisation des signaux.
 
---
 
## 2. Prérequis
 
### Matériel
 
- Une carte FPGA **Pynq-Z2**
- Un câble de connexion **UART** (USB vers série) branché sur le port **PMODA** (pins 1 à 6)
- Un câble **micro-USB** pour la programmation (JTAG)
 
### Logiciel
 
- **Vivado** (version 2025.2 ou supérieure)
- **Python 3.x** avec les bibliothèques suivantes installées :
  - `pyserial`
  - `neurokit2`
  - `numpy`
  - `matplotlib`
 
---
 
## 3. Configuration et Programmation du FPGA
 
### 3.1 Flashage avec Vivado
 
1. Décompressez l'archive dédiée au projet matériel Vivado.
2. Ouvrez Vivado > **Open Project** et sélectionnez le fichier `.xpr` présent dans le dossier décompressé.
3. Dans le panneau de gauche (**Flow Navigator**), cliquez sur **Generate Bitstream**.
4. Allumez le FPGA et connectez-le au PC via le port micro-USB.
5. Allez dans **Open Hardware Manager > Open Target > Auto connect**.
6. Cliquez sur **Program Device** pour flasher le bitstream sur la Pynq-Z2.
 
---
 
## 4. Communication avec le FPGA
 
L'interface de communication gère le protocole UART pour configurer le cœur ASCON-128, déclencher le chiffrement et récupérer les données sécurisées.
 
### 4.1 Détail des Commandes UART
 
La communication s'effectue en envoyant une **commande** (un octet correspondant à un caractère ASCII majuscule ou minuscule) suivie des données. Le FPGA renvoie systématiquement un accusé de réception (`OK\n`) après la bonne exécution d'une commande.
 
#### Initialisation des paramètres
 
| Commande | Code ASCII | Données | Description |
|----------|------------|---------|-------------|
| `A` / `a` | `0x41` / `0x61` | + 10 octets (avec padding) | **Données Associées** — données publiques authentifiées mais non chiffrées |
| `N` / `n` | `0x4E` / `0x6E` | + 16 octets | **Nonce** — valeur arbitraire et unique pour garantir la sécurité du chiffrement |
| `K` / `k` | `0x4B` / `0x6B` | + 16 octets | **Clé de chiffrement** — clé privée partagée entre le FPGA et le PC |
| `W` / `w` | `0x57` / `0x77` | + 184 octets | **Donnée à chiffrer** — waveform ECG préalablement paddée |
 
#### Exécution et Récupération
 
| Commande | Code ASCII | Description |
|----------|------------|-------------|
| `G` / `g` | `0x47` / `0x67` | **Lancement** de l'algorithme de chiffrement ASCON-128 |
| `C` / `c` | `0x43` / `0x63` | **Récupération du chiffré** — 184 octets du signal ECG chiffré |
| `T` / `t` | `0x54` / `0x74` | **Récupération du tag** — 16 octets du tag d'authentification pour vérifier l'intégrité |
 
---
 
## 5. Préparation et Exécution de l'Application Python
 
Une fois le FPGA configuré, le PC prend le relais pour piloter la carte, récupérer les données chiffrées et les analyser.
 
### 5.1 Mise en place de l'environnement
 
1. Décompressez la seconde archive dédiée au projet Python.
 
2. Ouvrez un terminal (invite de commandes, PowerShell ou le terminal de votre IDE) et naviguez jusqu'au dossier extrait.
 
3. Installez les dépendances requises :
 
```bash
pip install pyserial neurokit2 numpy matplotlib
```
 
4. Ouvrez le fichier `live_demo.py` avec un éditeur de texte. Repérez la ligne d'initialisation de la communication (vers la ligne 61) et vérifiez la configuration du port série :
 
```python
with IACQ(port="COM7", emulator=False) as fpga:
```
 
> Remplacez `"COM7"` par le port série correspondant à votre FPGA si nécessaire.
 
### 5.2 Analyse et Visualisation (Démonstration en direct)
 
Pour lancer l'application, exécutez la commande suivante dans votre terminal :
 
```bash
python live_demo.py
```
 
Le programme principal propose un pipeline complet et automatisé :
 
1. **Vérification de sécurité initiale** : Calcul et affichage des empreintes SHA256 des fichiers bitstreams pour s'assurer de leur authenticité avant de commencer.
 
2. **Chiffrement matériel** : Lecture continue d'un signal ECG depuis un fichier CSV (`xNorm.csv`), et envoi de chaque trame au FPGA en utilisant une clé, un nonce et des données associées prédéfinis.
 
3. **Déchiffrement et Authentification** : Récupération du texte chiffré et du tag depuis le FPGA, puis déchiffrement logiciel rigoureux (via `ascon_pcsn.py`) pour garantir l'intégrité de la trame.
 
4. **Analyse Physiologique Avancée** : Une fois un tampon de 1800 échantillons rempli, le signal est nettoyé et analysé par **NeuroKit2**. L'algorithme :
   - Isole les ondes (Q, R, S, T, P)
   - Calcule les métriques de variabilité de la fréquence cardiaque (HRV : SDNN, RMSSD, pNN50)
   - Détecte automatiquement d'éventuelles anomalies (Tachycardie, Bradycardie, Arythmie, Syndrome du QT long)
 
5. **Visualisation Dynamique** : Affichage en temps réel du signal ECG avec l'annotation colorée des différents pics physiologiques, complété par un **diagramme de Poincaré** (HRV).
