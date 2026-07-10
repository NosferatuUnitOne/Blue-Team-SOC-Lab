# Phase 6: Docker Setup

## Goal

Install and configure Docker as the container runtime for the SOAR components of the SOC lab.

Docker was used to run containerized security tools without manually installing every dependency directly on the host operating system. This made it easier to deploy Shuffle and prepare the lab for additional automation components.

---

## Role in the Architecture

Docker acts as the container layer for the SOAR side of the lab.

Instead of installing every application directly onto Ubuntu, Docker allows tools such as Shuffle and supporting services to run as isolated containers.

```text
Ubuntu VM
   ↓
Docker Engine
   ↓
Docker Compose
   ↓
Shuffle containers / supporting services
```

---

## Steps Completed

* Updated the Ubuntu package repository
* Installed Docker
* Installed Docker Compose v2
* Started and enabled the Docker service
* Verified Docker was running successfully
* Used Docker Compose to deploy Shuffle
* Confirmed containers were running with `docker ps`

---

## Installation

Docker was installed using `apt`:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
```

After installation, Docker was started and enabled on boot:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Docker was verified using:

```bash
docker --version
docker compose version
```

---

## Useful Docker Commands

Check running containers:

```bash
sudo docker ps
```

Check all containers, including stopped containers:

```bash
sudo docker ps -a
```

Check Docker logs for a specific container:

```bash
sudo docker logs <container_name> --tail=100
```

Start containers from a Compose file:

```bash
sudo docker compose up -d
```

Stop containers from a Compose file:

```bash
sudo docker compose down
```

---

## Issues Faced

* Docker Compose plugin package naming differed from the expected package name
* Multiple containers appeared after Shuffle was started
* Some Shuffle app containers looked like full applications, but were only Shuffle action containers
* TheHive was originally tested on the same VM as Shuffle, but this caused performance issues

---

## Fixes Applied

* Installed Docker Compose v2 using the available package for the Ubuntu VM
* Used `docker ps` to separate core containers from temporary Shuffle app containers
* Moved TheHive onto a separate VM to reduce load on the Shuffle VM
* Used Docker logs to troubleshoot backend and application behavior

---

## Verification

Docker was verified by checking the service status and running containers:

```bash
sudo systemctl status docker
sudo docker ps
```

The successful output confirmed that Docker was running and able to support the SOAR container stack.

---

## Lab Status

Docker is installed and functional.

It is currently being used as the container runtime for the SOAR side of the lab, especially Shuffle and its related services.
