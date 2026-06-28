# Phase 2: Graylog Server Setup

## Goal

Set up Graylog as the log management and SIEM interface for the SOC lab, using MongoDB for configuration storage and Wazuh Indexer/OpenSearch as the search backend.

## Lab Architecture

Graylog was deployed inside the Kali Linux VM, while MongoDB was hosted separately on the Windows host using Docker Desktop.

```text
Windows Host
└── Docker Desktop
    └── MongoDB container on port 27017

Kali Linux VM
├── Graylog Server
└── Wazuh Indexer / OpenSearch on port 9200
```

The Kali VM used a **Bridged Adapter**, allowing it to communicate with the Windows host over the local network.

---

## Steps Completed

* Installed Graylog Server on the Kali Linux VM
* Hosted MongoDB on the Windows host using Docker Desktop
* Published MongoDB on TCP port `27017`
* Verified MongoDB connectivity from the Kali VM using Netcat
* Configured Graylog’s `mongodb_uri` to point to the Windows host MongoDB container
* Configured Graylog’s `elasticsearch_hosts` to connect to Wazuh Indexer/OpenSearch
* Fixed TLS hostname verification issues between Graylog and the indexer
* Created and tested indexer credentials for Graylog
* Started and verified the Graylog server service
* Confirmed Graylog reached the “server up and running” state

---

## MongoDB Docker Setup

MongoDB was hosted on the Windows host instead of inside the Kali VM because MongoDB 5+ requires AVX support, and the VM environment was not exposing AVX properly.

The MongoDB container was started using Docker Desktop from PowerShell:

```powershell
docker run -d `
  --name graylog-mongo `
  --restart unless-stopped `
  -p 27017:27017 `
  -v graylog_mongo_data:/data/db `
  mongo:6
```

The container was verified using:

```powershell
docker ps
```

The expected result was for Docker to expose MongoDB on port `27017`, similar to:

```text
0.0.0.0:27017->27017/tcp
```

---

## Virtual Machine Network Configuration

The Graylog VM was configured with a **Bridged Adapter** in VirtualBox. This allowed the VM to appear as a separate machine on the same local network as the Windows host.

The Kali VM IP address was checked using:

```bash
ip addr
```

The Windows host IP address was checked using:

```powershell
ipconfig
```

During troubleshooting, it was important to use the Windows host’s real LAN adapter IP address, not the IP address from Hyper-V, WSL, Docker, or other virtual adapters.

Connectivity from the Graylog VM to MongoDB on the Windows host was tested using:

```bash
nc -vz <WINDOWS_HOST_IP> 27017
```

The result returned `open`, confirming that the Graylog VM could reach MongoDB over the local network.

---

## Graylog Configuration

The main Graylog configuration file was edited using:

```bash
sudo nano /etc/graylog/server/server.conf
```

The MongoDB URI was configured to point to the MongoDB container running on the Windows host:

```conf
mongodb_uri = mongodb://<WINDOWS_HOST_IP>:27017/graylog
```

The indexer/OpenSearch connection was configured using:

```conf
elasticsearch_hosts = https://<INDEXER_USERNAME>:<INDEXER_PASSWORD>@172.16.0.111:9200
```

The Graylog web interface settings were also configured:

```conf
http_bind_address = 0.0.0.0:9000
http_external_uri = http://172.16.0.111:9000/
```

This allowed the Graylog web interface to be accessed from another machine on the local network.

---

## Issues Faced

### MongoDB AVX Requirement

MongoDB 5+ requires AVX support. Since the Kali VM was not exposing AVX correctly, MongoDB could not reliably be hosted inside the VM.

### Windows Host and VM Networking

The Kali VM initially could not connect to the Windows host because the wrong Windows IP address was being tested. The IP address used was from a Hyper-V/virtual adapter instead of the real LAN adapter.

### Windows Firewall / Local Port Exposure

MongoDB was exposed on port `27017`, meaning the port was reachable on the local network. This required checking that Docker was publishing the port correctly and that Windows Firewall was not blocking the VM.

### Graylog and MongoDB Separation

Graylog was running inside the Kali VM, while MongoDB was running on the Windows host. This required setting `mongodb_uri` to the Windows host IP instead of `localhost`.

### TLS Hostname Verification

Graylog initially failed to connect to the Wazuh Indexer because it was connecting using the hostname `kali`, while the indexer certificate only contained the IP address `172.16.0.111` in its Subject Alternative Name.

The fix was to configure Graylog to connect to the indexer using the IP address:

```conf
elasticsearch_hosts = https://<USER>:<PASSWORD>@172.16.0.111:9200
```

### Indexer Authentication Issues

Graylog returned `Unauthorized` when connecting to the indexer because the wrong credentials or wrong username spelling was used.

One issue was caused by spelling the indexer user as `greylog` instead of `graylog`. Since Linux/OpenSearch usernames are exact, `greylog` and `graylog` are treated as completely different users.

### Role Mapping Confusion

Creating a new user in the indexer security dashboard was not enough by itself. The user also needed to be mapped to the correct OpenSearch/Wazuh Indexer role, such as `all_access`, or tested with a working admin account.

### Graylog Enterprise License Warning

Graylog displayed the following warning:

```text
Unable to write audit log entry because there is no valid license.
```

This warning was related to Graylog audit logging, which is an enterprise feature. It did not prevent the Graylog server from starting.

---

## Fixes Applied

* Hosted MongoDB on the Windows host using Docker Desktop
* Published MongoDB on port `27017`
* Used the correct Windows LAN adapter IP address
* Verified MongoDB connectivity from Kali using Netcat
* Set Graylog’s `mongodb_uri` to the Windows host IP
* Changed Graylog’s indexer connection from hostname `kali` to IP address `172.16.0.111`
* Used HTTPS instead of HTTP for the indexer connection
* Tested indexer credentials using `curl`
* Corrected the Graylog/indexer username spelling mismatch
* Restarted the Graylog service after configuration changes
* Confirmed Graylog reached the “server up and running” state

---

## Verification

MongoDB connectivity was verified from Kali using:

```bash
nc -vz <WINDOWS_HOST_IP> 27017
```

The Wazuh Indexer/OpenSearch connection was verified using:

```bash
curl -k -u '<USERNAME>:<PASSWORD>' 'https://172.16.0.111:9200'
```

The bulk indexing API was tested manually using:

```bash
curl -k -u 'admin:admin' \
  -H 'Content-Type: application/x-ndjson' \
  -X POST 'https://172.16.0.111:9200/_bulk?pretty' \
  --data-binary $'{ "index" : { "_index" : "graylog-test" } }\n{ "message" : "test from curl" }\n'
```

A successful response showed:

```json
"errors": false
```

Graylog service logs were monitored using:

```bash
sudo tail -f /var/log/graylog-server/server.log
```

Graylog successfully started with:

```text
Graylog server up and running.
```

The service status was checked using:

```bash
sudo systemctl status graylog-server
```

---

## What I Learned

* How Graylog uses MongoDB for configuration storage
* How Graylog connects to an OpenSearch-compatible indexer
* Why MongoDB 5+ requires AVX support
* How to work around VM CPU limitations by hosting MongoDB on the Windows host with Docker
* How bridged networking allows a VM to communicate with the host over the LAN
* Why using the correct network adapter IP matters
* How to test service connectivity using `nc`
* How to test HTTPS API access using `curl`
* Why TLS certificates require hostname/IP matching
* Why `localhost` changes meaning depending on which machine is using it
* The difference between Graylog users, MongoDB connectivity, and Wazuh Indexer/OpenSearch users
* How small username mistakes can cause authentication failures
* How to troubleshoot Linux services through logs and systemd
* How Docker, Windows networking, Linux services, and SIEM components interact in a lab environment

---

## Final Status

Graylog was successfully started and connected to its required backend services.

```text
MongoDB on Windows Docker: reachable
Wazuh Indexer/OpenSearch: reachable
Graylog Server: running
Graylog Web Interface: ready for access on port 9000
```

This completed the Graylog setup phase of the SOC lab.

