# ***SIMVA*** INFRASTRUCTURE WIKI

# ***SIM***ple ***VA***lidation (***SIMVA***)
[![SIMVA](https://raw.githubusercontent.com/e-ucm/simva-infra/master/.github/logo.svg?sanitize=true)](https://github.com/e-ucm/simva/)

Serious Games (SGs) are digital games designed for different purposes other than entertainment including providing knowledge, upgrading skills, and raising awareness. In fact, SGs were successfully implemented in different domains such as in military, business, medicine, schools, etc. Also, SGs present new opportunities to apply stealth assessment techniques for evaluating player performance, typically by analyzing  players interaction data.

Applying Game Learning Analytics (GLA) to these games enables the collection of, analysis and visualization of data derived from players' in-game interactions. However, when conducting such games, it is not enough to only collect game interaction data. In other words, SGs effectiveness should be measured too. This is because, in most SGs there are different stakeholders involved. 

Traditionally, educational tools effectiveness is measured through experiments which involve pre- and post-tests. These tests are usually conducted on paper or electronically. The issue is that these tests are ultimately isolated from the learning experience itself.

To conclude, with SGs there is a need to collect data from several resources during the different stages of an experiment. Also, there is a need to map these data for each user in order to give meaningful insights (user’s pre-assessment results, user’s in-game interaction data and user’s post-assessment results). Which raises several challenges in user management, data collection and analysis. 

Thus, there is a need for a tool that simplifies the assessment and enables a comprehensive management of the collected information. ***SIMVA*** tool addresses these challenges by offering integrated solutions. 

***SIMVA*** tool facilitates the application of Game Learning Analytics (GLA) in Serious Games (SGs), enabling the developers and the researchers to validate the effectiveness of these games. Also, it provides meaningful insights to different stakeholders which enables them to make the right decisions.

The following table shows in detail these challenges and the solutions provided by ***SIMVA***.

| Phase  | Challenge | Solution ***SIMVA*** provides |
| ------------- | ------------- | ------------- |
| Before an experiment  | - The lack of formal validation, or performed outside the game</br> - Managing surveys</br> - Managing users and providing anonymous identifiers to users|- Simplifying & supporting experimental design</br> - LimeSurvey encapsulation</br> - Token generation for users in keycloak|
| During an experiment, for example Pretest-Game-Postest  | - Collecting and storing surveys data</br> - Collecting and storing interactions traces data</br> -Relating those different data types to each user</br> - Teachers lack control when applying games in classes|- Survey data is stored in LimeSurvey database</br> - Trace data backup are stored in Minio as xAPI-SG format</br> - Using the same user token in the study process</br> - Support GLA remotely to conduct experiments in broader settings|
| After an experiment  | - Access of all data collected from different data sources</br> - Analysis of all data collected from different data sources</br>|- Data can be downloaded in the study page for the researcher</br> - TMon:  Default analysis and visualisation web tool for xAPI-SG data</br>|

This repository allows you to launch a complete ***SIMVA*** environment. 

## Instructions
### Requirements (OS):

* **Linux natively**: Follow step 1, then the steps from 4 to 6.
* **Windows** with the latest version of <a href="https://www.ucm.es/" target="_blank">Vagrant</a>  and the latest version of <a href="https://www.virtualbox.org/" target="_blank">VirtualBox</a>  (tested with 6.0): Follow the steps from 1 to 6.
* **Mac** with the latest version of <a href="https://www.ucm.es/" target="_blank">Vagrant</a>  and the latest version of <a href="https://www.virtualbox.org/" target="_blank">VirtualBox</a>  (tested with 6.0): Follow the steps from 1 to 6.

### Steps:
1. Clone this repository
2. Open a terminal in the cloned directory and run `vagrant up`
> Note: The first time you run this command it will take a long time because Vagrant needs to download, aprovision and install the base required software.
3. run `vagrant ssh` to get inside VM
4. run `cd docker-stacks`
5. run `./simva install`
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
