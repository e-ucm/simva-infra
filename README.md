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

## Instructions

1. Clone this repository
2. Verify that you have latest [Vagrant](https://vagrantup.com) and  [VirtualBox](https://www.virtualbox.org/) (tested with 6.0)
3. Open a terminal in the cloned directory and run `vagrant up`
> Note: The first time you run this command it will take a long time because Vagrant needs to download, aprovision and install the base required software.
4. run `vagrant ssh` to get inside VM
5. run `cd docker-stacks`
6. run `./simva install`
> Note: The first time you run this command it will take a long time because it is required to download all docker images required for SIMVA.
6. run `./simva start` to start all containers.
> Note: The first time you run this command it will take a long time because all componentes need to initialize.

# Acknowledgements

Authors of this project were supported by:

<table>
  <tr>
    <td width="30%">
      <a href="https://www.ucm.es/" target="_blank">
        <img width="100%" src="https://www.ucm.es/themes/ucm3/media/img/logo.png" alt="Universidad Complutense de Madrid logo"/>
      </a>
    </td>
    <td width="30%">
      <a href="https://impress-project.eu/" target="_blank">
        <img width="100%" src="https://www.inesc-id.pt/wp-content/uploads/2018/01/impress_logo_703x316.png" alt="IMPRESS Logo"/>
      </a>
    </td>
    <td width="30%">
      <a href="http://erasmusplus.nl/" target="_blank">
      <img width="100%" src="https://impress-project.eu/wp-content/uploads/2017/09/eu_flag_co_funded_700x200-300x86.png" alt="Erasmus+ Program Logo"/>
    </a>
  </td>
  </tr>
</table>

# License

This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/e-ucm/simva-infra/blob/master/LICENSE) file for details.

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

### (Windows) redirect ports using netsh

See:
- https://davidhamann.de/2019/06/20/setting-up-portproxy-netsh/
- https://docs.microsoft.com/en-us/windows-server/networking/technologies/netsh/netsh-interface-portproxy