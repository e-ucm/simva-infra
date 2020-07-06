# SIMple VAlidation (SIMVA)
[![SIMVA](https://raw.githubusercontent.com/e-ucm/simva-infra/master/.github/logo.svg?sanitize=true)](https://github.com/e-ucm/simva/)

SIMVA is a tool that helps Serious Games (SGs) developers / researchers to validate the efectiveness of SGs and to facilitate the application of Serious Games Learning Analytics in SGs.

Like any other educational tool, the traditional way of evaluating the effectiveness of the tool is through experiments that require a pre-post tests. Usually this is is done on paper or, in the best case scenario, electronically, but in the end these tests are disconected from the experiments themselves.

Moreover, SGs open new oportunities of applying a *stealth assessment* approach to evaluate players' performance. Usually this approach is implemented based on analytics that are gathered during the gameplay.

To be precise, SIMVA tool aims to simplify the possible issues:
 - Before the experiments:
   - Managing users & surveys
   - Providing anonymous identifiers to users
 - During the experiments:
 - Pretest-Game-Postest
   - Collecting and storing surveys and traces data (xAPI-SG)
   - Relating different data from users (GLA, tests)
 - After the experiments:
    - Simplifying downloading and analysis of all data collected

This respository allows you to to launch a complete SIMVA environment.

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