import serial
import logging
import time
from fpga_emulator import FPGAEmulator
from exception import (
    FPGAError, FPGAConnectionError, FPGAValidationError, 
    FPGATimeoutError, FPGAProtocolError, FPGAAuthenticationError
)
from ascon_pcsn import ascon_decrypt

logger = logging.getLogger(__name__)

class IACQ:
    def __init__(self, port: str, baud_rate: int = 115200, timeout: int = 1, emulator: bool = False, max_retries: int = 3) -> None:
        """
        Initialize IACQ communication interface.

        Args:
            port (str): Serial port (e.g., 'COM3' or '/dev/ttyUSB0').
            baud_rate (int, optional): Communication speed. Defaults to 115200.
            timeout (int, optional): Read timeout in seconds. Defaults to 1.
            emulator (bool, optional): If True, use software emulator instead of hardware. Defaults to False.
            max_retries (int, optional): Maximum number of reconnection attempts. Defaults to 3.
        """
        self.port = port
        self.baud_rate = baud_rate
        self.timeout = timeout
        self.use_emulator = emulator
        self.connection = None
        self.max_retries = max_retries

    def __enter__(self) -> 'IACQ':
        self.open()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> bool:
        self.close()
        return False

    def open(self) -> None:
        """Opens the connection to the FPGA or the emulator."""
        if self.use_emulator:
            logger.info("Ouverture de la connexion en mode Émulateur.")
            self.connection = FPGAEmulator()
            self.connection.open()
        else:
            logger.info(f"Ouverture de la connexion matérielle sur le port {self.port} à {self.baud_rate} bauds.")
            self.connection = serial.Serial(port=self.port, baudrate=self.baud_rate, timeout=self.timeout)

            self.connection.reset_input_buffer()
            self.connection.reset_output_buffer()

    def close(self) -> None:
        """Closes the connection safely."""
        if self.connection is not None and self.connection != 0:
            self.connection.close()
            self.connection = None
            logger.info("Connexion fermée proprement.")

    def reconnect(self) -> None:
        """
        Attempts to reconnect to the FPGA up to max_retries times.

        Raises:
            FPGAConnectionError: If reconnection fails after all attempts.
        """
        logger.warning("Reconnexion au FPGA...")
        self.close()    
        time.sleep(1) 
        
        for attempt in range(self.max_retries):
            try:
                self.open()
                logger.info(f"Reconnexion réussie (essai {attempt + 1})")
                return
            except Exception as e:
                logger.warning(f"Échec reconnexion {attempt + 1}/{self.max_retries} : {e}")
                time.sleep(1)
                
        logger.error("Impossible de rétablir la connexion.")
        raise FPGAConnectionError("Impossible de rétablir la connexion")

    def send_command(self, donnee: bytes) -> None:
        """
        Sends raw bytes to the FPGA.

        Args:
            donnee (bytes): The data/command to send.

        Raises:
            FPGAConnectionError: If the connection is not open.
        """
        if self.connection is None:
            logger.error("Tentative d'envoi mais la connexion n'est pas ouverte.")
            raise FPGAConnectionError("Erreur : La connexion n'est pas ouverte.")
        
        if len(donnee) > 0 and donnee[0] == 0x4B:
            logger.debug("TX : Commande K envoyée (Clé masquée)")
        else:
            logger.debug(f"TX : {donnee.hex()}")

        self.connection.write(donnee)

    def read_response(self) -> bytes:
        """
        Reads a line of response from the FPGA.

        Returns:
            bytes: The response from the FPGA.

        Raises:
            FPGAConnectionError: If the connection is not open.
            FPGATimeoutError: If no response is received.
        """
        if self.connection is None:
            logger.error("La connexion n'est pas ouverte.")
            raise FPGAConnectionError("Erreur : La connexion n'est pas ouverte.")
        
        response = self.connection.readline()
        if not response:
            raise FPGATimeoutError("Timeout : Aucune réponse reçue du FPGA.")
        else:
            logger.debug(f"RX : {response.hex()}")
        return response

    def _verify_ok(self) -> bytes:
        """
        Waits for and verifies an 'OK' acknowledgment from the FPGA.

        Returns:
            bytes: The response containing 'OK'.

        Raises:
            FPGAProtocolError: If the response is malformed.
            FPGATimeoutError: If the maximum retries are exceeded.
        """
        for attempt in range(self.max_retries):
            try:
                reponse = self.read_response()
                if b"OK" not in reponse:
                    raise FPGAProtocolError(f"Format inattendu. Reçu (hex) : {reponse.hex()}")
                logger.debug("Commande Ok")
                time.sleep(0.005)#pour eviter la desyncronisation UART/FSM
                return reponse
            except FPGATimeoutError:
                logger.warning(f"Timeout: Essai {attempt + 1}/{self.max_retries}...")
                if attempt == self.max_retries - 1:
                    raise 
                time.sleep(0.5)

    def send_key(self, key: bytes) -> None:
        """
        Sends the 16-byte encryption key to the FPGA.

        Args:
            key (bytes): 16-byte key.

        Raises:
            FPGAValidationError: If the key length is incorrect.
        """
        if not isinstance(key, bytes) or len(key) != 16:
            raise FPGAValidationError("La clé doit faire exactement 16 octets.")
        logger.info("Envoi de la clé (K)...")
        self.send_command(bytes([0x4B]) + key)
        self._verify_ok()

    def send_nonce(self, nonce: bytes) -> None:
        """
        Sends the 16-byte nonce to the FPGA.

        Args:
            nonce (bytes): 16-byte nonce.

        Raises:
            FPGAValidationError: If the nonce length is incorrect.
        """
        if not isinstance(nonce, bytes) or len(nonce) != 16:
            raise FPGAValidationError("Le nonce doit faire exactement 16 octets.")
        logger.info("Envoi du nonce (N)...")
        self.send_command(bytes([0x4E]) + nonce)
        self._verify_ok()

    def send_associated_data(self, ad: bytes) -> None:
        """
        Sends the associated data to the FPGA with appropriate padding.

        Args:
            ad (bytes): Associated data (max 8 bytes).

        Raises:
            FPGAValidationError: If the associated data exceeds 8 bytes.
        """
        if not isinstance(ad, bytes) or len(ad) > 8:
            raise FPGAValidationError("Les données associées ne doivent pas dépasser 8 octets.")
        
        vrai_padding_ascon = ad + b'\x80' + b'\x00' * (7 - len(ad))
        padding = vrai_padding_ascon + b'\x80\x00'    

        logger.info(f"Envoi des données associées (A) (Taille paddée: {len(padding)} octets)...")
        self.send_command(bytes([0x41]) + padding)
        self._verify_ok()

    def send_waveform_to_fpga(self, waveform: bytes) -> None:
        """
        Sends the 181-byte ECG waveform to the FPGA.

        Args:
            waveform (bytes): 181-byte ECG signal.

        Raises:
            FPGAValidationError: If the waveform length is incorrect.
        """
        if not isinstance(waveform, bytes) or len(waveform) != 181:
            raise FPGAValidationError("Le signal doit faire exactement 181 octets.")
        
        padding = waveform + b'\x80\x00\x00'
        logger.info(f"Envoi du signal ECG (W) (Taille paddée: {len(padding)} octets)...")
        self.send_command(bytes([0x57]) + padding)
        self._verify_ok()

    def start_encryption(self) -> None:
        """Triggers the ASCON encryption process on the FPGA."""
        logger.info("Démarrage du chiffrement (G) sur le FPGA...")
        self.send_command(bytes([0x47]))
        self._verify_ok()

    def get_tag(self) -> bytes:
        """
        Retrieves the 16-byte authentication tag from the FPGA.

        Returns:
            bytes: The 16-byte ASCON authentication tag.

        Raises:
            FPGAProtocolError: If the response is invalid or too short.
        """
        logger.info("Demande du Tag (T)...")
        self.send_command(bytes([0x54]))
        reponse = self.connection.read(16)  

        self._verify_ok()
        if reponse is None or len(reponse) < 16:
            raise FPGAProtocolError("Réponse invalide pour le tag.")
        
        tag = reponse[:16]
        logger.debug(f"Tag reçu : {tag.hex()}")
        return tag

    def get_ciphertext(self) -> bytes:
        """
        Retrieves the 181-byte ciphertext from the FPGA.

        Returns:
            bytes: The encrypted waveform.

        Raises:
            FPGAProtocolError: If the response is invalid or too short.
        """
        logger.info("Demande du cyphertext (C) au FPGA...")
        self.send_command(bytes([0x43]))
        reponse = self.connection.read(184)

        self._verify_ok()
        if reponse is None or len(reponse) < 184:
            raise FPGAProtocolError("Réponse invalide ou trop courte pour le texte chiffré.")
        
        ciphertext = reponse[:181] 
        logger.debug(f"Texte chiffré reçu ({len(ciphertext)} octets).")
        return ciphertext

    # ------------------------ High level ---------------------------

    def encrypt_on_fpga(self, waveform: bytes, key: bytes, nonce: bytes, associated_data: bytes) -> tuple[bytes, bytes]:
        """
        Executes the full encryption pipeline on the FPGA.

        Args:
            waveform (bytes): 181-byte plaintext ECG signal.
            key (bytes): 16-byte encryption key.
            nonce (bytes): 16-byte nonce.
            associated_data (bytes): Up to 8 bytes of associated data.

        Returns:
            tuple[bytes, bytes]: A tuple containing (ciphertext, tag).
        """
        logger.info("=== Lancement de la séquence de chiffrement complète ===")
        self.send_key(key)
        self.send_nonce(nonce)
        self.send_associated_data(associated_data)
        self.send_waveform_to_fpga(waveform)
        
        self.start_encryption()
        
        tag = self.get_tag()
        ciphertext = self.get_ciphertext()
        
        return ciphertext, tag

    def decrypt_waveform(self, ciphertext: bytes, tag: bytes, key: bytes, nonce: bytes, associated_data: bytes) -> bytes:
        """
        Decrypts the waveform using the software ASCON implementation.

        Args:
            ciphertext (bytes): The encrypted data.
            tag (bytes): The 16-byte authentication tag.
            key (bytes): The 16-byte encryption key.
            nonce (bytes): The 16-byte nonce.
            associated_data (bytes): The associated data.

        Returns:
            bytes: The decrypted plaintext waveform.

        Raises:
            FPGAAuthenticationError: If authentication fails (wrong key, modified data, etc.).
        """
        logger.debug("Déchiffrement logiciel via ascon_pcsn...")
        data_to_decrypt = ciphertext + tag
        
        try:
            decrypted = ascon_decrypt(key, nonce, associated_data, data_to_decrypt)
        except Exception as e:
            raise FPGAAuthenticationError(f"Erreur interne lors du déchiffrement : {e}")

        if decrypted is None:
            raise FPGAAuthenticationError("Échec de l'authentification : Tag invalide.")
            
        return decrypted