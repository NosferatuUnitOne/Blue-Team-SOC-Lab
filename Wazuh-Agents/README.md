# Phase 5: Wazuh Agent Deployment

## Goal

Deploy Wazuh Agents on endpoint machines and connect them to the Wazuh Manager for centralized log collection, endpoint monitoring, and security event visibility.

The Wazuh Agent is responsible for collecting logs and endpoint activity from monitored systems, then forwarding that data to the Wazuh Manager. This allows the SOC lab to detect activity from Windows and Linux machines through the Wazuh Dashboard.

---

## Role in the Architecture

Wazuh Agents act as the endpoint telemetry source in the SOC lab.

They collect data from endpoints such as:

* Authentication logs
* System logs
* Security events
* File integrity monitoring data
* Process and service activity
* Windows event logs
* Linux system activity

The collected data is forwarded to the Wazuh Manager, processed, indexed, and then displayed through the Wazuh Dashboard.

```text
Endpoint Machine
Windows / Linux
      |
      | Logs and Events
      v
Wazuh Agent
      |
      | Port 1514 / 1515
      v
Wazuh Manager
      |
      v
Wazuh Indexer
      |
      v
Wazuh Dashboard
```

---

## Steps Completed

* Installed the Wazuh Agent on a Windows endpoint
* Installed the Wazuh Agent on a Linux endpoint
* Configured the agents to communicate with the Wazuh Manager
* Used the Wazuh Manager IP address during agent enrollment
* Started and enabled the Wazuh Agent services
* Verified agent status from the endpoint
* Confirmed that the agents appeared inside the Wazuh Dashboard
* Confirmed that endpoint activity could be monitored through the SOC lab

---

## Windows Agent Installation

The Windows endpoint was configured with the Wazuh Agent so that Windows logs and endpoint activity could be forwarded to the Wazuh Manager.

The agent was installed using the Wazuh Windows installer and configured with the Wazuh Manager IP address.

Example PowerShell command:

```powershell
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="MANAGER_IP_ADDRESS" WAZUH_REGISTRATION_SERVER="MANAGER_IP_ADDRESS"
```

After installation, the Wazuh Agent service was started using:

```powershell
NET START WazuhSvc
```

The service status was checked using:

```powershell
Get-Service WazuhSvc
```

Expected result:

```text
Running
```

---

## Linux Agent Installation

The Linux endpoint was configured with the Wazuh Agent so that Linux system activity could be forwarded to the Wazuh Manager.

The Wazuh repository was already configured from the earlier phases of the SOC lab.

The Wazuh Agent was installed using:

```bash
sudo WAZUH_MANAGER="MANAGER_IP_ADDRESS" apt install wazuh-agent
```

After installation, the service was enabled and started:

```bash
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

The service status was checked using:

```bash
sudo systemctl status wazuh-agent
```

Expected result:

```text
Active: active (running)
```

---

## Agent Configuration

The Wazuh Agent configuration file stores the manager connection settings.

### Windows Agent Configuration Path

```text
C:\Program Files (x86)\ossec-agent\ossec.conf
```

### Linux Agent Configuration Path

```text
/var/ossec/etc/ossec.conf
```

The manager connection is defined inside the `<client>` section:

```xml
<client>
  <server>
    <address>MANAGER_IP_ADDRESS</address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
</client>
```

This configuration tells the agent where to send collected logs and security events.

---

## Issues Faced

* Needed to confirm that the Wazuh Manager IP address was correct
* Needed to make sure the Wazuh Agent service was running properly
* Needed to verify that the endpoint could communicate with the manager
* Windows PowerShell syntax caused issues when using Linux-style environment variable formatting
* Agent enrollment required the correct registration settings and manager-side configuration

---

## Fixes Applied

* Used the correct PowerShell syntax for Windows agent installation
* Verified the manager IP address before starting the agent
* Restarted the Wazuh Agent service after configuration changes
* Checked service status from the endpoint
* Confirmed that the agent appeared as active in the Wazuh Dashboard

---

## Verification

The Wazuh Agents were verified using both endpoint-side and manager-side checks.

### Endpoint Verification

Windows:

```powershell
Get-Service WazuhSvc
```

Linux:

```bash
sudo systemctl status wazuh-agent
```

### Manager-Side Verification

On the Wazuh Manager, connected agents can be checked using:

```bash
sudo /var/ossec/bin/agent_control -l
```

Expected output example:

```text
ID: 001, Name: windows-endpoint, IP: any, Active
ID: 002, Name: linux-endpoint, IP: any, Active
```

### Dashboard Verification

The Wazuh Dashboard was used to confirm that the agents were connected and active.

Dashboard path:

```text
Wazuh > Agents
```

Expected status:

```text
Active
```

---

## Testing Agent Log Collection

To confirm that the agents were forwarding activity properly, basic test commands were run on the endpoints.

### Windows Test Activity

```powershell
whoami
ipconfig
ping google.com
```

### Linux Test Activity

```bash
whoami
sudo su
ping google.com
```

These commands were used to generate basic endpoint activity that could later be viewed and analyzed through Wazuh.

---

## What I Learned

* How Wazuh Agents connect endpoint machines to the Wazuh Manager
* How endpoint logs are collected and forwarded into the SOC lab
* How Windows and Linux agents differ during installation and service management
* Why correct manager IP configuration is important
* How to verify agent health from both the endpoint and the dashboard
* How agents provide the SOC with visibility into real endpoint activity

This phase helped complete the basic log pipeline of the SOC lab by adding monitored endpoint machines into the Wazuh environment.

Without deployed agents, the SIEM would have limited visibility. Adding agents turns the lab from only having backend services into an actual monitoring environment with endpoint telemetry.

---

## Screenshots

## Windows Agent Service Verification

![Windows Agent Service Verification](./Windows-Agent-Service.png)

## Linux Agent Service Verification

![Linux Agent Service Verification](./Linux-Agent-Service.png)

## Wazuh Dashboard Agent Status

![Wazuh Dashboard Agent Status](./Agent-Active-Dashboard.png)

## Agent Log Activity Verification

![Agent Log Activity Verification](./Agent-Log-Activity.png)

---

## Status

```text
Wazuh Agent Deployment: Completed
Windows Agent: Active
Linux Agent: Active
Manager Connection: Verified
Dashboard Visibility: Confirmed
```

