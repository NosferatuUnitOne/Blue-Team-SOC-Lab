# Phase 3: Wazuh Manager Setup

## Goal

Set up the Wazuh Manager as the central security monitoring component of the SOC lab.

The Wazuh Manager is responsible for receiving, processing, and analyzing security events from Wazuh agents. It acts as the core detection engine in the Wazuh stack and works together with the Wazuh Indexer and Dashboard.

---

## Steps Completed

* Installed the Wazuh Manager package using `apt`
* Started the Wazuh Manager service
* Enabled the service to start automatically on boot
* Verified that the service was running successfully
* Confirmed that the Wazuh Manager was ready for agent connections

---

## Installation

The Wazuh repository had already been added during the earlier Wazuh Indexer setup phase.

The Wazuh Manager was installed using:

```bash
sudo apt install wazuh-manager
```

After installation, the service was started using:

```bash
sudo systemctl start wazuh-manager
```

The service was also enabled to start automatically on boot:

```bash
sudo systemctl enable wazuh-manager
```

---

## Service Verification

The Wazuh Manager service status was checked using:

```bash
sudo systemctl status wazuh-manager
```

A successful result showed that the service was active and running.

Additional verification commands used:

```bash
sudo systemctl is-active wazuh-manager
```

```bash
sudo systemctl is-enabled wazuh-manager
```

---

## Logs

Wazuh Manager logs can be checked using:

```bash
sudo tail -f /var/ossec/logs/ossec.log
```

This log file is useful for checking manager startup messages, agent connection activity, errors, and general Wazuh service behavior.

---

## Issues Faced

This setup phase was straightforward compared to the Wazuh Indexer and Graylog setup.

No major issues were encountered during the Wazuh Manager installation.

The main requirement was making sure that:

* The Wazuh repository was already configured
* The package installed correctly through `apt`
* The service started successfully through `systemctl`

---

## Fixes Applied

No major fixes were required.

The Wazuh Manager installed and started successfully after installation.

---

## Verification

The manager was verified using:

```bash
sudo systemctl status wazuh-manager
```

The logs were checked using:

```bash
sudo tail -f /var/ossec/logs/ossec.log
```

The successful service status confirmed that the Wazuh Manager was running and ready to receive data from agents.

---

## What I Learned

* The Wazuh Manager acts as the central analysis and detection component of the Wazuh stack
* The manager receives events from Wazuh agents
* The manager processes security events before they are indexed and displayed
* `systemctl` is used to start, stop, enable, and verify Wazuh services
* Wazuh Manager logs are stored under `/var/ossec/logs/`
* Not every setup phase requires heavy troubleshooting; some components can be deployed cleanly when dependencies and repositories are already configured

---

## Final Status

The Wazuh Manager was successfully installed and started.

```text
Wazuh Manager: running
Service startup: enabled
Manager logs: accessible
Ready for agent connections
```

This completed the Wazuh Manager setup phase of the SOC lab.

