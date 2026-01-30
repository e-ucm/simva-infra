# ***SIMVA*** INFRASTRUCTURE WIKI

# ***SIM***ple ***VA***lidation (***SIMVA***)
[![SIMVA](https://raw.githubusercontent.com/e-ucm/simva-infra/master/.github/logo.svg?sanitize=true)](https://github.com/e-ucm/simva/)

Serious Games (SGs) are digital games designed for different purposes other than entertainment. For example, SGs can be designed to provide knowledge, upgrade skills, or raise awareness. In fact, SGs were successfully implemented in different domains such as in military, business, medicine, schools, etc. Also, SGs present new opportunities to apply stealth assessment techniques for evaluating player's performance, typically by analyzing  player's interaction data.

Applying Game Learning Analytics (GLA) to these games enables the collection, analysis and visualization of data derived from player's in-game interactions. However, when conducting such games, it is not enough to only collect game interaction data. In other words, SGs effectiveness should be measured too. This is because, in most SGs there are different stakeholders involved. 

Traditionally, educational tools effectiveness is measured through experimental sessions which involve pre- and post-surveys. These surveys are usually conducted on paper or electronically. The issue is that these surveys are ultimately isolated from the learning experience itself.

To conclude, with SGs there is a need to collect data from several resources during the different stages of a session. Also, there is a need to map these data for each participnat in order to give meaningful insights (participnat’s pre-survey results, participnat’s in-game interaction data and participnat’s post-survey results). Which raises several challenges in user management, data collection and analysis. 

Thus, there is a need for a tool that simplifies the assessment with pre and post surveys and enables a comprehensive management of the collected information. ***SIMVA*** tool addresses these challenges by offering integrated solutions. 

***SIMVA*** tool facilitates the application of Game Learning Analytics (GLA) in Serious Games (SGs), enabling the developers and the researchers to validate the effectiveness of these games. Also, it provides meaningful insights to different stakeholders which enables them to make the right decisions.

The following table shows in detail these challenges and the solutions provided by ***SIMVA***.

| Phase  | Challenge | Solution ***SIMVA*** provides |
| ------------- | ------------- | ------------- |
| Before the session  | - The lack of formal validation, or performed outside the game</br> - Managing surveys</br> - Managing users and providing anonymous identifiers to participnats|- Simplifying & supporting experimental design</br> - LimeSurvey encapsulation</br> - Token generation for participnats in keycloak|
| During the session, for example PreSurvey-GamePlay-PostSurvey  | - Collecting and storing surveys data</br> - Collecting and storing interactions traces data</br> -Relating those different data types to each participnat</br> - Teachers lack control when applying games in classes|- Surveys data is stored in LimeSurvey database</br> - Trace data backup are stored in Minio as xAPI-SG format</br> - Using the same participnat token during the whole session</br> - Support GLA remotely to conduct  sessions in broader settings|
| After the session  | - Access of all data collected from different data sources</br> - Analysis of all data collected from different data sources</br>|- Data can be downloaded from a visual dashboard</br> - TMon:  Default analysis and visualisation web tool for xAPI-SG data</br>|

This repository allows you to launch a complete ***SIMVA*** environment. 

## Instructions
### Requirements (OS):

* **Linux natively**: Follow steps 1 and 2, then step 5.
* **Windows** with the latest version of <a href="https://vagrantup.com" target="_blank">Vagrant</a> (✅ tested with Vagrant Version: Vagrant 2.4.9) and the latest version of <a href="https://www.virtualbox.org/" target="_blank">VirtualBox</a> (✅ tested with VBoxManage Version: 7.2.2r170484): Follow the steps from 1 to 5.
* **Mac** with the latest version of <a href="https://vagrantup.com" target="_blank">Vagrant</a> (✅ tested with Vagrant Version: Vagrant 2.4.9) and the latest version of <a href="https://www.virtualbox.org/" target="_blank">VirtualBox</a> (✅ tested with VBoxManage Version: 7.2.2r170484): Follow the steps from 1 to 5.

### Steps:
1. Clone this repository
1. Change the git branch to choosen branch.
1. Open a terminal in the cloned directory and change directory to vagrant directory using command `cd ./vagrant`.
1. Run `./2-run-vagrant-image.ps1` in Windows or `./2-run-vagrant-image.sh` in Mac or Linux machine.
> Note: The first time you run this command it will take a long time because Vagrant needs to download, aprovision and install the base required software.
> Note: You can configure the RAM and CPU of the VM corresponding of your own computer with the parameters : `--Memory <int> --CPU <int>` in Windows (by default : 8196=8Go and 8) or `--memory <int> --CPU <int>` in Mac or Linux machine (by default : 4096=4Go and 8).
5. Inside VM, run `cd ./simva-infra/docker-stacks/ && sudo su` and run `./simva start` to start all containers.
> Note: The first time you run this command it will take a long time because all components need to initialize.

## Local development connect to simva server

 To launch VSCode Server, you can use VSCode running `./3-run-vscode-vagrant.ps1` in Windows or `./3-run-vscode-vagrant.sh` in MacOS or Linux.

## Stopping and reloading the VM 

To stop the VM, run `./2-run-vagrant-image.ps1 -Stop` in Windows or `./2-run-vagrant-image.sh --stop` in MacOS or Linux .
To reload the VM, Run `./2-run-vagrant-image.ps1 -Reload` in Windows or `./2-run-vagrant-image.sh --reload` in MacOS or Linux.

## Notes

By default Vagrant maps the following ports:
- 8080 (host) -> 80 (guest)
- 8443 (host) -> 443 (guest)

To simplify things you may want to apply the following instructions in order to map to regular ports using the OS firewall / capabilities.

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
