package es.eucm.keycloak.lti13;

public class ConfigParameterParseException extends RuntimeException {
    
    public ConfigParameterParseException(String message) {
        super(message);
    }
    
    public ConfigParameterParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
