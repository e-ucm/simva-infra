package es.eucm.keycloak.lti13;

import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URIBuilder;
import org.jboss.logging.Logger;
import org.keycloak.models.AuthenticatedClientSessionModel;
import org.keycloak.models.ClientModel;
import org.keycloak.models.ClientSessionContext;
import org.keycloak.models.KeycloakContext;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.ProtocolMapperContainerModel;
import org.keycloak.models.ProtocolMapperModel;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserSessionModel;
import org.keycloak.protocol.ProtocolMapperConfigException;
import org.keycloak.protocol.oidc.mappers.AbstractOIDCProtocolMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAccessTokenMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAttributeMapperHelper;
import org.keycloak.protocol.oidc.mappers.OIDCIDTokenMapper;
import org.keycloak.protocol.oidc.mappers.UserInfoTokenMapper;
import org.keycloak.provider.ProviderConfigProperty;
import org.keycloak.provider.ProviderConfigurationBuilder;
import org.keycloak.representations.IDToken;

import es.eucm.keycloak.lti13.JsonRemoteClaimException;
import es.eucm.keycloak.lti13.ConfigParameterParseException;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


import jakarta.ws.rs.HttpMethod;
/*
import jakarta.ws.rs.ProcessingException;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.ResponseProcessingException;
import org.jboss.resteasy.client.jaxrs.ResteasyClient;
import org.jboss.resteasy.client.jaxrs.ResteasyClientBuilder;
import org.jboss.resteasy.client.jaxrs.internal.ResteasyClientBuilderImpl;
import org.jboss.resteasy.client.jaxrs.internal.ClientInvocation;
import org.jboss.resteasy.client.jaxrs.ResteasyWebTarget;
import jakarta.ws.rs.core.Form;
import jakarta.ws.rs.core.HttpHeaders;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;

import org.jboss.resteasy.spi.HttpRequest;
import org.jboss.resteasy.plugins.server.BaseHttpRequest;
*/

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 
 * XXX Verify if it is required add LTI attributes all tokens
 */
public class LTI13OIDCProtocolMapper extends AbstractOIDCProtocolMapper
        implements OIDCAccessTokenMapper, OIDCIDTokenMapper, UserInfoTokenMapper {
    public static final String PROVIDER_ID = "oidc-lti13-mapper";

    private static final Logger LOGGER = Logger.getLogger(LTI13OIDCProtocolMapper.class);

    private static final String PAIRS_SEPARATOR = ",";

    private static final String PARAMETER_SEPARATOR = "=";

    private static final String PLATFORM_CTXT = "lti3_platform";

    private static final String PLATFORM_URL = PLATFORM_CTXT + ".url";

    private static final String PLATFORM_PARAMETERS = PLATFORM_CTXT + ".parameters";

    private static final String PLATFORM_HEADERS = PLATFORM_CTXT + ".headers";

    private final static String REMOTE_REQUEST_METHOD = PLATFORM_PARAMETERS + ".method";

    private final static String REMOTE_PARAMETERS_USERNAME = PLATFORM_PARAMETERS + ".username";

    private final static String REMOTE_PARAMETERS_CLIENTID = PLATFORM_PARAMETERS + ".clientid";

    private static final String REMOTE_PARAMETERS_USER_ATTRIBUTES = PLATFORM_PARAMETERS + ".user.attributes";

    private static final String REMOTE_HEADERS_BEARER_TOKEN = PLATFORM_HEADERS + ".bearer.token";

    private static final String CLIENT_AUTH_URL = PLATFORM_CTXT + ".auth.url";

    private static final String CLIENT_AUTH_ID = PLATFORM_CTXT + ".auth.id";

    private static final String CLIENT_AUTH_PASS = PLATFORM_CTXT + ".auth.pass";

    private static final ObjectMapper MAPPER;

    private static final List<ProviderConfigProperty> configProperties;

    /**
     * Inner configuration to cache retrieved authorization for multiple tokens
     */
    private final static String LTI13_CLAIMS_ATTR = "lti13-claims";
    
    //private static ResteasyClient CLIENT;

    static {
        // @formatter:off
        configProperties = ProviderConfigurationBuilder.create()
        .property()
        .name(PLATFORM_URL)
        .type(ProviderConfigProperty.STRING_TYPE).label("Platform URL")
        .helpText("IMS LTI 1.3 Platform API endpoint URL.")
        .add()
        // Headers
        .property()
        .name(PLATFORM_HEADERS)
        .label("Headers")
        .type(ProviderConfigProperty.STRING_TYPE)
        .helpText(
                "List of name"+PARAMETER_SEPARATOR+"value pairs sent as headers. Use '"+PAIRS_SEPARATOR+"' to separate pairs (e.g. Authorization"+PARAMETER_SEPARATOR+"az89d"+PAIRS_SEPARATOR+"X-Vendor"+PARAMETER_SEPARATOR+"true).")
        .add()
        // Parameters
        .property()
        .name(PLATFORM_PARAMETERS)
        .type(ProviderConfigProperty.STRING_TYPE)
        .label("Parameters")
        .helpText(
            "List of name"+PARAMETER_SEPARATOR+"value pairs sent as request parameters. Use '"+PAIRS_SEPARATOR+"' to separate pairs (e.g. scope"+PARAMETER_SEPARATOR+"all"+PAIRS_SEPARATOR+"full"+PARAMETER_SEPARATOR+"true)."
        )
        .add()
        // Request method
        .property()
        .name(REMOTE_REQUEST_METHOD)
        .label("Request method")
        .type(ProviderConfigProperty.LIST_TYPE)
        .options(HttpMethod.GET, HttpMethod.POST)
        .helpText("HTTP request method to use")
        .defaultValue(HttpMethod.POST)
        .add()
        // Username
        .property()
        .name(REMOTE_PARAMETERS_USERNAME)
        .label("Send user name")
        .type(ProviderConfigProperty.BOOLEAN_TYPE)
        .helpText("Send the username as request parameter (param: username).")
        .defaultValue("true")
        .add()
        // Client_id
        .property()
        .name(REMOTE_PARAMETERS_CLIENTID)
        .label("Send client ID")
        .type(ProviderConfigProperty.BOOLEAN_TYPE)
        .helpText("Send the client_id as request parameter (param: client_id).")
        .defaultValue("false")
        .add()
        // User attributes
        .property()
        .name(REMOTE_PARAMETERS_USER_ATTRIBUTES)
        .label("User attributes")
        .type(ProviderConfigProperty.STRING_TYPE)
        .helpText("Send custom user attributes as request parameters. Separate value by '"+PARAMETER_SEPARATOR+"'.")
        .add()
        // Bearer token
        .property()
        .name(REMOTE_HEADERS_BEARER_TOKEN)
        .label("Send bearer token")
        .type(ProviderConfigProperty.BOOLEAN_TYPE)
        .helpText("If active, use below params to get a client_credentials access token and send it as bearer auth token.")
        .add()
        // Client auth url
        .property()
        .name(CLIENT_AUTH_URL)
        .label("AS token endpoint URL")
        .type(ProviderConfigProperty.STRING_TYPE)
        .helpText("Absolute URL of the token endpoint (e.g. http://example.com/realms/my-realm/protocol/openid-connect/token).")
        .defaultValue("")
        .add()
        // Client id
        .property()
        .name(CLIENT_AUTH_ID)
        .label("Client Id")
        .type(ProviderConfigProperty.STRING_TYPE)
        .helpText("client Id used to connect to the token endpoint.")
        .add()
        // Client password
        .property()
        .name(CLIENT_AUTH_PASS)
        .label("Client secret")
        .type(ProviderConfigProperty.PASSWORD)
        .secret(true)
        .helpText("Client secret used to connect to the token endpoint.")
        .add()
        //
        .build();
        // @formatter:on
        OIDCAttributeMapperHelper.addAttributeConfig(configProperties, LTI13OIDCProtocolMapper.class);

        //CLIENT = ((ResteasyClientBuilder) ClientBuilder.newBuilder()).build();
        MAPPER = new ObjectMapper();
    }

    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        return configProperties;
    }

    /**
     * Called when instance of mapperModel is created/updated for this
     * protocolMapper through admin endpoint
     *
     * @param session
     * @param realm
     * @param client      client or clientTemplate
     * @param mapperModel
     * @throws ProtocolMapperConfigException if configuration provided in
     *                                       mapperModel is not valid
     */
    @Override
    public void validateConfig(KeycloakSession session, RealmModel realm, ProtocolMapperContainerModel client,
            ProtocolMapperModel mapperModel) throws ProtocolMapperConfigException {
        
        String configValue = mapperModel.getConfig().get(PLATFORM_URL);
        if (configValue == null || configValue.trim().isEmpty()) {
            String label = getConfigProperties().stream().filter((p) -> p.getName().equals(PLATFORM_URL)).findFirst()
                    .get().getLabel();
            throw new ProtocolMapperConfigException("error", "{0}", label + " must not be empty");
        }

        try {
            configValue = mapperModel.getConfig().get(PLATFORM_PARAMETERS);
            buildMapFromConfigString(configValue);
        } catch (ConfigParameterParseException e) {
            throw new ProtocolMapperConfigException("error", "{0}", PLATFORM_PARAMETERS + " has invalid value", e);
        }

        try {
            configValue = mapperModel.getConfig().get(PLATFORM_HEADERS);
            buildMapFromConfigString(configValue);
        } catch (ConfigParameterParseException e) {
            throw new ProtocolMapperConfigException("error", "{0}", PLATFORM_HEADERS + " has invalid value", e);
        }
    }

    @Override
    public String getDisplayCategory() {
        return TOKEN_MAPPER_CATEGORY;
    }

    @Override
    public String getDisplayType() {
        return "LTI 1.3 claims mapper";
    }

    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    @Override
    public String getHelpText() {
        return "Add required claims for a LTI 1.3";
    }


    @Override
    protected void setClaim(IDToken token, ProtocolMapperModel mappingModel, UserSessionModel userSession,
            KeycloakSession keycloakSession, ClientSessionContext clientSessionCtx) {
        JsonNode claims = clientSessionCtx.getAttribute(LTI13_CLAIMS_ATTR, JsonNode.class);
        /*
        if (claims == null) {
            KeycloakContext ctx = keycloakSession.getContext();
            //HttpRequest req = context.getHttpRequest();
            //org.jboss.resteasy.spi.HttpRequest req = ctx.getContextObject(org.jboss.resteasy.spi.HttpRequest.class);
            HttpRequest req = ctx.getContextObject(BaseHttpRequest.class);
            MultivaluedMap<String, String> params;
            if(HttpMethod.GET.equals(req.getHttpMethod())) {
                params = req.getUri().getQueryParameters();
            } else {
                params = req.getFormParameters();
            }
            claims = getClaims(params, mappingModel, userSession, clientSessionCtx);
            clientSessionCtx.setAttribute(LTI13_CLAIMS_ATTR, claims);
        }

        String protocolClaim = mappingModel.getConfig().get(OIDCAttributeMapperHelper.TOKEN_CLAIM_NAME);
        if (protocolClaim != null && ! protocolClaim.isEmpty()) {
            OIDCAttributeMapperHelper.mapClaim(token, mappingModel, claims);
        } else {
            Map<String, Object> mapClaims = MAPPER.convertValue(claims, new TypeReference<Map<String, Object>>() {});
            token.getOtherClaims().putAll(mapClaims);
        }
        */
        OIDCAttributeMapperHelper.mapClaim(token, mappingModel, claims);
    }
    
    /*
    private JsonNode getClaims(MultivaluedMap<String, String> reqParameters, ProtocolMapperModel mappingModel,
            UserSessionModel userSession, ClientSessionContext clientSessionCtx) {
        // Get parameters
        Map<String, String> parameters = getRequestsParameters(mappingModel, userSession, clientSessionCtx);
        reqParameters.forEach((k, v)-> {
            if (v.size() > 0) {
                parameters.put(k, v.get(0));
            }
        });

        // Get headers
        Map<String, String> headers = getHeaders(mappingModel, userSession, clientSessionCtx);

        // Call remote service
        final String url = mappingModel.getConfig().get(PLATFORM_URL);

        return post(url, headers, parameters);
    }
    */
    
    private Map<String, String> getRequestsParameters(ProtocolMapperModel mappingModel, UserSessionModel userSession,
            ClientSessionContext clientSessionCtx) {

        final boolean sendUsername = "true".equals(mappingModel.getConfig().get(REMOTE_PARAMETERS_USERNAME));

        final boolean sendClientID = "true".equals(mappingModel.getConfig().get(REMOTE_PARAMETERS_CLIENTID));

        final String configuredUserAttributes = mappingModel.getConfig().get(REMOTE_PARAMETERS_USER_ATTRIBUTES);

        // Get parameters
        final Map<String, String> parameters = buildMapFromConfigString(
                mappingModel.getConfig().get(PLATFORM_PARAMETERS));

        // Get client ID
        if (sendClientID) {
            if (clientSessionCtx != null) {
                parameters.put("client_id", clientSessionCtx.getClientSession().getClient().getClientId());
            } else {
                parameters.put("client_id",
                        userSession.getAuthenticatedClientSessions().values().stream()
                                .map(AuthenticatedClientSessionModel::getClient).map(ClientModel::getClientId)
                                .distinct().collect(Collectors.joining(",")));
            }
        }

        // Get username
        if (sendUsername) {
            parameters.put("username", userSession.getLoginUsername());
        }

        // Get custom user attributes
        if (configuredUserAttributes != null && !"".equals(configuredUserAttributes.trim())) {
            List<String> userAttributes = Arrays.asList(split(configuredUserAttributes.trim(), PAIRS_SEPARATOR));
            userAttributes.forEach(
                    attribute -> parameters.put(attribute, userSession.getUser().getFirstAttribute(attribute)));
        }

        return parameters;
    }
    /*
    private Map<String, String> getHeaders(ProtocolMapperModel mappingModel, UserSessionModel userSession,
            ClientSessionContext clientSessionCtx) {
        final String configuredHeaders = mappingModel.getConfig().get(PLATFORM_HEADERS);
        final boolean sendBearerToken = "true".equals(mappingModel.getConfig().get(REMOTE_HEADERS_BEARER_TOKEN));

        // Get headers
        Map<String, String> headers = buildMapFromConfigString(configuredHeaders);
        if (sendBearerToken) {
            String signedRequestToken = getClientToken(mappingModel);
            headers.put(HttpHeaders.AUTHORIZATION, "Bearer " + signedRequestToken);
        }
        return headers;
    }
    */
    /*
    private JsonNode get(String url, Map<String, String> headers, Map<String, String> parameters) {
        try {
            URIBuilder uriBuilder = new URIBuilder(url);
            // Build queryParameters
            parameters.forEach(uriBuilder::setParameter);
            url = uriBuilder.build().toURL().toString();
        } catch (URISyntaxException e) {
            throw new JsonRemoteClaimException("Error building URL", url, e);
        } catch (MalformedURLException e) {
            throw new JsonRemoteClaimException("Error building URL", url, e);
        }

        return request(HttpMethod.POST, url, headers, null);
    }

    private JsonNode post(String url, Map<String, String> headers, Map<String, String> parameters) {
        return request(HttpMethod.POST, url, headers, parameters);
    }

    private JsonNode request(String method, String url, Map<String, String> headers, Map<String, String> formParameters) {
        URIBuilder uriBuilder;
        URI uri;
        try {
            uriBuilder = new URIBuilder(url);
            uri = uriBuilder.build();
            url = uri.toURL().toString();
        } catch (URISyntaxException e) {
            throw new JsonRemoteClaimException("Error building URL", url, e);
        } catch (MalformedURLException e) {
            throw new JsonRemoteClaimException("Error building URL", url, e);
        }

        Entity<Form> entity = null;
        if (formParameters.size() > 0) {
            Form form = new Form();
            // Build parameters
            formParameters.entrySet().forEach((kv) -> form.param(kv.getKey(), kv.getValue()));
            entity = Entity.entity(form, MediaType.APPLICATION_FORM_URLENCODED_TYPE);
        }

        if (LOGGER.isDebugEnabled()) {
            logRequest(uri, formParameters);
        }

        ResteasyWebTarget target = CLIENT.target(url);
        Response response;
        try {
            ClientInvocation.Builder builder = target.request(MediaType.APPLICATION_JSON);
            // Build headers
            for (Map.Entry<String, String> header : headers.entrySet()) {
                builder.header(header.getKey(), header.getValue());
            }
            if (entity != null) {
                response = builder.method(method, entity);
            } else {
                response = builder.method(method);
            }
            
        } catch(ResponseProcessingException e) {
            //In case processing of a received HTTP response fails (e.g. in a
            //filter or during conversion of the response entity data to an 
            //instance of a particular Java type).
            throw new JsonRemoteClaimException("Error when accessing remote claim", url, e);
        } catch(ProcessingException e) {
            //In case the request processing or subsequent I/O operation fails.
            throw new JsonRemoteClaimException("Error when accessing remote claim", url, e);
        }

        // Check response status
        if (response.getStatus() != 200) {
            response.close();
            throw new JsonRemoteClaimException("Wrong status received for remote claim - Expected: 200, Received: " + response.getStatus(), url);
        }

        // Bind JSON response
        try {
            return response.readEntity(JsonNode.class);
        } catch(RuntimeException e) {
            // exceptions are thrown to prevent token from being delivered without all information
            throw new JsonRemoteClaimException("Error when parsing response for remote claim", url, e);
        } finally {
            response.close();
        }
    }
    */
    /*
    private void logRequest(URI uri, Map<String, String> formParameters) {
        URIBuilder builder = new URIBuilder(uri);
        List<NameValuePair> queryParams = builder.getQueryParams().stream().map((nvp) -> {
            if (nvp.getName().toLowerCase().indexOf("secret") > 0 
                || nvp.getName().toLowerCase().indexOf("pass") > 0) {
                return new SimpleNameValuePair(nvp.getName(), "**REDACTED**");
            }
            return nvp;
        }).collect(Collectors.toList());
        builder.setParameters(queryParams);
        String debugUrl="";
        try {
            debugUrl = uri.toURL().toString();
        } catch (MalformedURLException e) {
            LOGGER.debug("Oops", e);
        }
        List<Map.Entry<String, String>> debugFormParams = formParameters.entrySet().stream().map((kv) -> {
            if (kv.getKey().toLowerCase().indexOf("secret") > 0 
                || kv.getValue().toLowerCase().indexOf("pass") > 0) {
                return new SimpleNameValuePair(kv.getKey(), "**REDACTED**");
            }
            return kv;
        }).collect(Collectors.toList());
        LOGGER.debugf("Request: url=%s ; params=%s", debugUrl, debugFormParams.toString());
    }

    private String getClientToken(ProtocolMapperModel mappingModel) {
        // Get headers
        Map<String, String> headers = Collections.emptyMap();
        Map<String, String> parameters = new HashMap<>();
        parameters.put("grant_type", "client_credentials");
        parameters.put("client_id", mappingModel.getConfig().get(CLIENT_AUTH_ID));
        parameters.put("client_secret", mappingModel.getConfig().get(CLIENT_AUTH_PASS));

        // Call remote service
        String baseUrl = mappingModel.getConfig().get(CLIENT_AUTH_URL);
        JsonNode jsonNode = post(baseUrl, headers, parameters);
        if (!jsonNode.has("access_token")) {
            throw new JsonRemoteClaimException("Access token not found", baseUrl);
        }
        return jsonNode.findValue("access_token").asText();
    }
    */
    
    private Map<String, String> buildMapFromConfigString(String value) {
        final Map<String, String> map = new HashMap<>();

        if (value != null) {
            String[] pairs = split(value.trim(), PAIRS_SEPARATOR);
            int pos;
            for (String pair : pairs) {
                pos = pair.indexOf(PARAMETER_SEPARATOR);
                if (pos == -1) {
                    throw new ConfigParameterParseException("Invalid multivalued parameter");
                } else {
                    String pairParam = pair.substring(0, pos);
                    String pairValue = pos < pair.length() ? pair.substring(pos+1) : "";
                    map.put(pairParam, pairValue );
                }
            }
        }

        return map;
    }

    private String[] split(String str, String separator) {
        List<String> result = new ArrayList<>();
        StringBuilder buffer = new StringBuilder();
        int initial = 0;
        int pos;
        while ((pos = str.indexOf(separator, initial)) != -1) {
            if (pos > 0 && str.charAt(pos-1) == '\\') {
                // escaped separator -> append the content + separator
                buffer.append(str.substring(initial, pos-1)).append(",");
            } else {
                result.add(buffer.toString());
                buffer.setLength(0);
            }
            initial = pos+separator.length();
        }
        return result.toArray(new String[0]);
    }

    private static class SimpleNameValuePair implements NameValuePair, Map.Entry<String, String> {

        private String name;

        private String value;

        public SimpleNameValuePair(String name, String value) {
            this.name = name;
            this.value = value;
        }

        @Override
        public String getName() {
            return this.name;
        }

        @Override
        public String getValue() {
            return this.value;
        }

        @Override
        public String getKey() {
            return this.name;
        }

        @Override
        public String setValue(String value) {
            String old = this.value;
            this.value = value;
            return old;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ((name == null) ? 0 : name.hashCode());
            result = prime * result + ((value == null) ? 0 : value.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            SimpleNameValuePair other = (SimpleNameValuePair) obj;
            if (name == null) {
                if (other.name != null)
                    return false;
            } else if (!name.equals(other.name))
                return false;
            if (value == null) {
                if (other.value != null)
                    return false;
            } else if (!value.equals(other.value))
                return false;
            return true;
        }
    }
}
