# Architecture Matérielle — ASCON FPGA
 
## `fpga_version_final` — Synthèse & Déploiement Matériel
 
C'est le système complet, optimisé pour être programmé sur la carte FPGA et communiquer avec un ordinateur.
 
- **Top Level (`Ascon_top.sv`)** : Module principal qui câble l'horloge, le reset, le cœur de chiffrement et les périphériques.
 
- **Interface PC (`fsm_uart.sv`)** : Contrôleur UART et sa machine d'état pour décoder les commandes ASCII (`K/k`, `N/n`, `A/a`, `W/w`, `G/g`, `C/c`, `T/t`) envoyées par l'utilisateur.
 
- **Stockage BRAM** : Instanciation de mémoires internes double-port pour stocker la trame d'entrée et les résultats (Cipher/Tag), avec gestion des adresses et multiplexage des données.
 
- **Contraintes physiques (`ctr_top.xdc`)** : Mapping des broches physiques du FPGA (horloge 125 MHz, bouton de reset, ports série Rx/Tx) et configuration des sondes de debug (ILA).
 
> **⚠️ Note sur le Testbench (`Ascon_tb.sv`)** : Il est possible d'activer le testbench pour relancer des simulations complètes. Cependant, ce fichier est actuellement **désactivé** et doit le rester lors de la génération du Bitstream afin d'éviter tout conflit lors du déploiement sur la carte.
