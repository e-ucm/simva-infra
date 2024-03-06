package es.eucm.keycloak.policyroleattributemapper;

import org.keycloak.models.ClientSessionContext;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.ProtocolMapperModel;
import org.keycloak.models.UserSessionModel;
import org.keycloak.models.RoleModel;
import org.keycloak.protocol.ProtocolMapperUtils;
import org.keycloak.protocol.oidc.OIDCLoginProtocol;
import org.keycloak.protocol.oidc.mappers.AbstractOIDCProtocolMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAccessTokenMapper;
import org.keycloak.protocol.oidc.mappers.OIDCAttributeMapperHelper;
import org.keycloak.protocol.oidc.mappers.OIDCIDTokenMapper;
import org.keycloak.protocol.oidc.mappers.UserInfoTokenMapper;
import org.keycloak.provider.ProviderConfigProperty;
import org.keycloak.representations.AccessToken;
import org.keycloak.representations.IDToken;

import java.util.*;
import java.util.stream.*;

public class PolicyRoleAttributeMapper extends AbstractOIDCProtocolMapper implements OIDCAccessTokenMapper, OIDCIDTokenMapper, UserInfoTokenMapper {
    public static final String PROVIDER_ID = "policy-role-attribute-mapper";

    private static final List<ProviderConfigProperty> configProperties = new ArrayList<>();

    static {
        OIDCAttributeMapperHelper.addTokenClaimNameConfig(configProperties);
        OIDCAttributeMapperHelper.addIncludeInTokensConfig(configProperties, PolicyRoleAttributeMapper.class);
    }

    @Override
    public String getDisplayCategory() {
        return "Token mapper";
    }

    @Override
    public String getDisplayType() {
        return "Role Policy Attribute Mapper";
    }

    @Override
    public String getHelpText() {
        return "Maps the 'policy' role attribute to a token claim 'policy'";
    }

    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        return configProperties;
    }

    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    @Override
    protected void setClaim(IDToken token, ProtocolMapperModel mappingModel,
      UserSessionModel userSession, KeycloakSession keycloakSession,
      ClientSessionContext clientSessionCtx) {
        List<String> attValues = new ArrayList<>();
        String ATTRIBUTE_NAME = "policy";
        boolean FLATTEN_IF_ONLY_ONE_VALUE = true;

        // Fetch the effective role mappings
        Stream<RoleModel> roleMappings = userSession.getUser().getRoleMappingsStream();

        // Iterate over effective roles and extract attributes
        roleMappings.forEach(role -> {
            Map<String, List<String>> attrs = ((RoleModel)role).getAttributes();
            if (attrs != null && attrs.containsKey(ATTRIBUTE_NAME)) {
                List<String> value = attrs.get(ATTRIBUTE_NAME);
                if (FLATTEN_IF_ONLY_ONE_VALUE) {
                    attValues.addAll(value);
                } else {
                    attValues.add(String.join(",", value));
                }
            }
        });
        System.out.println(attValues);
        OIDCAttributeMapperHelper.mapClaim(token, mappingModel, String.join(",", attValues));
    }

    public static ProtocolMapperModel create(String name,
                                             boolean accessToken, boolean idToken, boolean userInfo) {
        ProtocolMapperModel mapper = new ProtocolMapperModel();
        mapper.setName(name);
        mapper.setProtocolMapper(PROVIDER_ID);
        mapper.setProtocol(OIDCLoginProtocol.LOGIN_PROTOCOL);
        Map<String, String> config = new HashMap<String, String>();
        config.put(OIDCAttributeMapperHelper.INCLUDE_IN_ACCESS_TOKEN, "true");
        config.put(OIDCAttributeMapperHelper.INCLUDE_IN_ID_TOKEN, "true");
        mapper.setConfig(config);
        return mapper;
    }
}