passwordhashed=$(docker run --rm httpd:2.4-alpine htpasswd -nbB ${SIMVA_TRAEFIK_DASHBOARD_USER:-admin} ${SIMVA_TRAEFIK_DASHBOARD_PASSWORD:-password} | cut -d ":" -f 2)
echo $passwordhashed > "${SIMVA_CONFIG_HOME:-/home/vagrant/docker-stacks/config}/traefik/traefik-password-hashed.txt"