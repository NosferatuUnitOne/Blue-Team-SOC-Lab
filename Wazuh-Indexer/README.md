# Phase 1: Wazuh Indexer Setup

## Goal
Set up the Wazuh Indexer as the search and storage component of the SOC lab.

## Steps Completed
- Installed Wazuh repository and GPG key
- Installed Wazuh Indexer
- Generated and deployed certificates
- Configured `opensearch.yml`
- Set file permissions and ownership
- Started and verified the service

## Issues Faced
- Service failed on first startup
- Certificate path mismatch
- Memory/heap configuration issue

## Fixes Applied
- Corrected certificate filenames
- Updated permissions using `chmod 400`
- Assigned ownership to `wazuh-indexer`
- Adjusted JVM heap settings

## Verification
- Checked service status with `systemctl status wazuh-indexer`
- Reviewed logs in `/var/log/wazuh-indexer/`
- Confirmed dashboard/indexer connectivity where applicable

## What I Learned
- How Wazuh Indexer fits into the SOC stack
- Why certificate permissions matter
- How OpenSearch-based services use TLS
- How to troubleshoot failed Linux services

## Screenshots

![Checking Active Status Of Wazuh Indexer](./Wazuh-Indexer/Indexer-Active.png)

