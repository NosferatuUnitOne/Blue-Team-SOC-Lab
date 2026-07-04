# Blue Team SOC Lab

This repository documents my ongoing SOC lab build, focused on blue team operations, log collection, detection, SIEM integration, and cloud/security monitoring concepts.

## Environment
- Kali Linux VM
- VirtualBox
- Local lab network

## GOAL

Build and document a functional Blue Team SOC lab using Wazuh, log collection, detection workflows, and eventually cloud-based security monitoring.

## Lab Phases

| Phase | Component | Status | Documentation |
|---|---|---|---|
| 1 | Wazuh Indexer | Completed | [View Docs](./Wazuh-Indexer/README.md) |
| 2 | Wazuh Dashboard | Completed | [View Docs](./Wazuh-Dashboard/README.md) |
| 3 | Wazuh Manager | Completed | [View Docs](./Wazuh-Manager/README.md) |
| 4 | Filebeat | Completed | [View Docs](./Filebeat/README.md) |
| 5 | Wazuh Agents | Completed | [View Docs](./Wazuh-Agents/README.md)

## Archived-Experiments

| Component | Status | Documentation |
|---|---|---|
| Graylog | Compatibility Mismatch | [View Docs](./Archived-Experiments/Graylog/README.md) |

## Log Pipline Architecture

![Log Pipeline Architecture Diagram](./SIEM-STACK-ARCHITECTURE-LOG-PIPELINE.png)
