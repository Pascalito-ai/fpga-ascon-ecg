
class FPGAError(Exception):
    """Exception de base pour toutes les erreurs liées au FPGA."""
    pass

class FPGAConnectionError(FPGAError):
    """La connexion n'a pas pu être établie ou a été perdue."""
    pass

class FPGATimeoutError(FPGAError):
    """Le FPGA n'a pas répondu dans le délai imparti (timeout)."""
    pass

class FPGAValidationError(FPGAError):
    """Les données d'entrée n'ont pas passé la validation (mauvais type, mauvaise taille, etc.)."""
    pass

class FPGAProtocolError(FPGAError):
    """La réponse du FPGA était malformée ou inattendue."""
    pass

class FPGAAuthenticationError(FPGAError):
    """L'authentification ASCON a échoué."""
    pass