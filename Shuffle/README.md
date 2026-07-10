# Phase 7: Shuffle SOAR Integration

## Goal

Set up Shuffle as the SOAR automation layer for the SOC lab.

Shuffle receives alerts from Wazuh through a webhook and forwards selected security alerts into TheHive for analyst review and case management.

---

## Role in the Architecture

Shuffle acts as the automation bridge between Wazuh and TheHive.

```text
Wazuh Manager
   ↓
custom-shuffle.py integration
   ↓
Shuffle Webhook
   ↓
TheHive Create Alert action
   ↓
TheHive OmarSOC Alerts Queue
```

The purpose of this phase was to move from simple SIEM alerting into a more realistic SOC workflow where alerts can be routed, enriched, and turned into analyst-reviewable items.

---

## Steps Completed

* Installed Docker and Docker Compose v2 on the Shuffle VM
* Cloned and started Shuffle using Docker Compose
* Accessed the Shuffle web interface
* Created a workflow for Wazuh alert intake
* Created a Shuffle webhook
* Configured Wazuh Manager to send alerts to the Shuffle webhook
* Created a TheHive action inside Shuffle
* Tested manual webhook delivery using `curl`
* Tested Wazuh alert forwarding using failed SSH login activity
* Confirmed Shuffle received Wazuh alert payloads
* Confirmed Shuffle was able to send alerts into TheHive

---

## Shuffle Deployment

Shuffle was started using Docker Compose:

```bash
cd ~/Shuffle
sudo docker compose up -d
```

Running containers were checked using:

```bash
sudo docker ps
```

The Shuffle interface was accessed through the VM IP address:

```text
http://<SHUFFLE_VM_IP>:3001
https://<SHUFFLE_VM_IP>:3443
```

---

## Wazuh Webhook Test

The Shuffle webhook was tested manually using `curl`:

```bash
curl -k -i -X POST "https://<SHUFFLE_VM_IP>:3443/api/v1/hooks/<WEBHOOK_ID>" \
  -H "Content-Type: application/json" \
  -d '{"source":"manual-test","message":"hello from Omar lab","status":"webhook working"}'
```

A successful response confirmed that the webhook endpoint was working:

```text
HTTP/1.1 200 OK
{"success": true}
```

---

## Wazuh Integration Script

A custom Wazuh integration script was used to send Wazuh alerts into Shuffle.

Script path:

```bash
/var/ossec/integrations/custom-shuffle.py
```

The script reads a Wazuh alert JSON file, wraps it into a payload, and sends it to the Shuffle webhook.

Important payload fields included:

```json
{
  "source": "wazuh",
  "integration": "custom-shuffle",
  "sent_at": "<timestamp>",
  "alert": {}
}
```

---

## Wazuh Manager Configuration

The Wazuh Manager was configured to send high-level alerts to Shuffle.

```xml
<integration>
  <name>custom-shuffle.py</name>
  <hook_url>https://<SHUFFLE_VM_IP>:3443/api/v1/hooks/<WEBHOOK_ID></hook_url>
  <level>10</level>
  <alert_format>json</alert_format>
</integration>
```

The Wazuh Manager was restarted after editing the configuration:

```bash
sudo systemctl restart wazuh-manager
```

---

## TheHive Action Body

The Shuffle workflow used a TheHive action to create an alert.

A working body used a dynamic `sourceRef` from the Wazuh payload:

```json
{
  "title": "Wazuh Alert",
  "description": "Wazuh alert received through Shuffle.",
  "type": "external",
  "source": "wazuh",
  "sourceRef": "$exec.sent_at",
  "severity": 2,
  "tlp": 2,
  "pap": 2,
  "tags": ["wazuh", "shuffle", "thehive", "soc-lab"]
}
```

The `sourceRef` value must be unique. A static `sourceRef` only works once because TheHive prevents duplicate alerts with the same source and reference.

---

## Issues Faced

* Initial webhook tests failed because of incorrect curl syntax
* Wrong protocol and port caused failed webhook requests
* Shuffle initially returned failed responses while its backend/OpenSearch services were still initializing
* Wazuh initially sent too many lower-level alerts
* TheHive alert creation failed when Shuffle used a missing variable: `$exec.execution_id`
* TheHive returned `400 BadRequest` and `Invalid json` when the body contained a variable that Shuffle could not resolve

---

## Fixes Applied

* Used the correct HTTPS webhook endpoint on port `3443`
* Waited for Shuffle backend services to fully initialize
* Restricted Wazuh forwarding to level `10` and higher alerts
* Replaced the missing `$exec.execution_id` variable with `$exec.sent_at`
* Used a unique `sourceRef` to avoid duplicate alert rejection
* Tested TheHive API access directly with `curl` before testing the full Shuffle workflow

---

## Verification

The full workflow was tested using failed SSH login activity.

```text
Failed SSH login attempt
   ↓
Wazuh generated a high-level alert
   ↓
Wazuh custom integration sent the alert to Shuffle
   ↓
Shuffle received the webhook payload
   ↓
Shuffle created an alert in TheHive
```

The successful result confirmed that the SOC alert pipeline was working end-to-end.

---

## Lab Status

Shuffle is currently integrated with Wazuh and TheHive.

The lab can now route Wazuh alerts into TheHive through a SOAR workflow.
