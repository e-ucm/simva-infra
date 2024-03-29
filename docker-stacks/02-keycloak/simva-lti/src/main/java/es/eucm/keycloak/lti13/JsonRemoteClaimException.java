package es.eucm.keycloak.lti13;

public class JsonRemoteClaimException extends RuntimeException {

    public JsonRemoteClaimException(String message, String url) {
        super(message + " - Configured URL: " + url);
    }

    public JsonRemoteClaimException(String message, String url, Throwable cause) {
        super(message + " - Configured URL: " + url, cause);
    }

}