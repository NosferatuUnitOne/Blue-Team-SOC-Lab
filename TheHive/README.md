# Phase 8: TheHive Alert Management

## Goal

Set up TheHive as the alert and case management platform for the SOC lab.

TheHive is used to receive alerts from Shuffle, organize analyst review, and prepare the lab for future incident response workflows.

---

## Role in the Architecture

TheHive acts as the analyst-facing alert management layer.

```text
Wazuh Alert
   ↓
Shuffle SOAR Workflow
   ↓
TheHive Alert
   ↓
Analyst Review / Case Creation
```

In this lab, TheHive receives Wazuh alerts through Shuffle and stores them under the `OmarSOC` organization.

---

## Steps Completed

* Deployed TheHive on a separate Ubuntu VM
* Used Docker Compose to run TheHive and supporting services
* Accessed TheHive through the web interface
* Created the `OmarSOC` organization
* Created a normal user for analyst access
* Created a service user for Shuffle API access
* Generated an API key for the Shuffle service user
* Verified TheHive web access from the Shuffle VM
* Verified TheHive API authentication using `curl`
* Verified direct alert creation using the TheHive API
* Connected Shuffle to TheHive using the API key
* Confirmed alerts could be created in TheHive from Shuffle

---

## Deployment

TheHive was deployed on a separate VM to avoid overloading the Shuffle VM.

The original attempt placed TheHive and Shuffle on the same VM, but the environment became slow due to disk I/O pressure from multiple containerized services.

The final layout became:

```text
VM3 = Shuffle / SOAR
VM4 = TheHive
```

---

## TheHive Access

TheHive was accessed from the browser using:

```text
http://<THEHIVE_VM_IP>:9000
```

In the lab, the working TheHive instance URL was:

```text
http://172.16.0.237:9000
```

Only the base URL should be used in Shuffle.

Correct:

```text
http://172.16.0.237:9000
```

Incorrect:

```text
http://172.16.0.237:9000/administration/organisations/OmarSOC/users
```

The longer URL is only a browser page inside the TheHive interface, not the API base URL.

---

## Users and Organization

TheHive was configured with an organization for the SOC lab:

```text
Organization: OmarSOC
```

Two users were created:

```text
Normal user:
- Used to log in and view alerts
- Organization: OmarSOC
- Profile: org-admin or analyst

Service user:
- Used by Shuffle for API access
- Login: shuffle@omarsoc.local
- Organization: OmarSOC
- Profile: analyst
```

The Shuffle service user is not meant for normal browsing. It exists so Shuffle can authenticate to TheHive and create alerts through the API.

---

## API Authentication Test

The API key was tested from the Shuffle VM using:

```bash
curl -i -H "Authorization: Bearer <THEHIVE_API_KEY>" \
  http://172.16.0.237:9000/api/v1/user/current
```

A successful response returned:

```text
HTTP/1.1 200 OK
```

The response confirmed:

```text
User: shuffle@omarsoc.local
Organization: OmarSOC
Profile: analyst
Permission: manageAlert/create
```

---

## Direct Alert Creation Test

Before troubleshooting Shuffle, TheHive alert creation was tested directly through the API.

```bash
curl -i -X POST "http://172.16.0.237:9000/api/v1/alert" \
  -H "Authorization: Bearer <THEHIVE_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Direct API Test Alert",
    "description": "Created directly with curl from Shuffle VM.",
    "type": "external",
    "source": "curl-test",
    "sourceRef": "curl-test-001",
    "severity": 2,
    "tlp": 2,
    "pap": 2,
    "tags": ["curl", "shuffle", "thehive", "test"]
  }'
```

A successful response returned:

```text
HTTP/1.1 201 Created
```

This confirmed that TheHive, the API key, and the `OmarSOC` organization were working correctly.

---

## Issues Faced

* Alerts did not appear at first because the wrong area of TheHive was being viewed
* The default admin area only showed platform administration, not the analyst alert queue
* The normal user had to log into the `OmarSOC` workspace to view alerts
* Shuffle initially failed to create alerts because of an invalid JSON body
* A static `sourceRef` only allowed one alert to be created before duplicates were rejected
* TheHive and Shuffle on the same VM caused performance issues

---

## Fixes Applied

* Logged in as the normal `OmarSOC` user to view alerts
* Created a dedicated Shuffle service user inside the same organization
* Used the base TheHive instance URL in Shuffle
* Verified TheHive API access using `curl`
* Used a unique dynamic `sourceRef` value when creating alerts
* Moved TheHive to its own VM for better performance

---

## Verification

TheHive was verified in three stages:

```text
1. Browser access to TheHive UI
2. API authentication test with /api/v1/user/current
3. Alert creation test with /api/v1/alert
```

After TheHive was connected to Shuffle, alerts appeared in the `OmarSOC` alert queue.

---

## Lab Status

TheHive is installed, accessible, and integrated with Shuffle.

The SOC lab can now receive Wazuh alerts and display them inside TheHive for analyst review.
