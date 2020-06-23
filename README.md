# simva-infra

Environment to launch a complete SIMVA environment.


https://docs.docker.com/compose/compose-file/#variable-substitution
https://docs.docker.com/compose/environment-variables/#the-env-file

## Notes

By default Vagrant maps the following ports:
- 8080 (host) -> 80 (guest)
- 8443 (host) -> 443 (guest)

To simplify things you may want to apply the following instructions in order to map to regular ports using the OS firewall / capabilities.

### (Linux) redirect ports using iptables

```
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -t nat -I PREROUTING 1 -p tcp --dport 443 -d 127.0.0.1 -j REDIRECT --to-ports 8443
sudo iptables -t nat -I PREROUTING 1 -p tcp --dport 80  -d 127.0.0.1 -j REDIRECT --to-ports 8080
# https://serverfault.com/questions/211536/iptables-port-redirect-not-working-for-localhost
# PREROUTING isn't used by the loopback interface, you need to also add an OUTPUT rule:
sudo iptables -t nat -I OUTPUT -p tcp -o lo -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080
sudo iptables -t nat -I OUTPUT -p tcp -o lo -d 127.0.0.1 --dport 443 -j REDIRECT --to-ports 8443
```