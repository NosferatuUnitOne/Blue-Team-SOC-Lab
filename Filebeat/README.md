# Phase 4: Filebeat Integration

## Goal

Configure Filebeat as the log shipping component between the Wazuh Manager and the Wazuh Indexer.

## Why Filebeat Replaced Graylog

Graylog was originally tested as an additional log management layer, but it introduced version compatibility issues with Graylog 6.6, OpenSearch, and the Wazuh Indexer.

Filebeat was chosen instead because it is part of the standard Wazuh deployment flow and integrates more directly with the Wazuh Manager, Indexer, and Dashboard.

## Role in the Architecture

Filebeat forwards processed Wazuh alerts from the Wazuh Manager to the Wazuh Indexer, where they can be searched and visualized through the Wazuh Dashboard.

## Steps Completed

- Installed Filebeat
- Configured Filebeat to communicate with the Wazuh Indexer
- Deployed the Wazuh Filebeat module/template
- Configured certificates for secure communication
- Started and enabled the Filebeat service
- Verified that Filebeat was shipping alerts successfully

## Issues Faced

- Replaced Graylog due to compatibility issues
- Needed to confirm correct certificate paths
- Needed to verify Filebeat-to-Indexer connectivity
- Needed to confirm alerts were reaching the Wazuh Dashboard

## Issue with bootup due to `usr/share/filebeat/module/wazuh` not being found

![Issue with Bootup](./Filebeat-Bootup-Error.png)


