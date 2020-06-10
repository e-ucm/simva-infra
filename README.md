# simva-infra

Environment to launch a complete SIMVA environment.

## Notes

### (Linux) redirect ports using iptables

```
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -t nat -I PREROUTING 1 -p tcp --dport 443 -j REDIRECT --to-ports 8443
sudo iptables -t nat -I PREROUTING 1 -p tcp --dport 80 -j REDIRECT --to-ports 8080
# https://serverfault.com/questions/211536/iptables-port-redirect-not-working-for-localhost
# PREROUTING isn't used by the loopback interface, you need to also add an OUTPUT rule:
sudo iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-ports 8080
sudo iptables -t nat -I OUTPUT -p tcp -o lo --dport 443 -j REDIRECT --to-ports 8443
```