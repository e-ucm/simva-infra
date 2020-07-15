
- Why using docker socket proxy?
  - TL;DR if there is a bug in the software that has access to docker socket proxy your host can be compromised.
  - https://medium.com/@containeroo/traefik-2-0-paranoid-about-mounting-var-run-docker-sock-22da9cb3e78c
- Why using tecnativa/docker-socket-proxy ?
  - It is a custom haproxy that provides a limited, read-only, version of the docker API.
  - In the context of using traefik allows us to move traefik to worker nodes while this container listens on managers and only allows traefik to connect, read-only, to limited docker api calls (souce: https://github.com/BretFisher/dogvscat/blob/master/stack-proxy-global.yml#L124).