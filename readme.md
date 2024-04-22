# DevOps Docker Image

## Description
Docker image with stuff I use as a DevOps Engineer. The image is available [on the ghcr](https://github.com/Maxine-N/DevOps-Container/pkgs/container/devops-container) and can be pulled with `docker pull ghcr.io/maxine-n/devops-container:main`. There's also a [docker-compose.yaml](docker-compose.example.yaml) which includes mounts for the ssh and kube config so the config from the host system can be used.

## What's inside

### IaC Tools
- Ansible
- Terraform

### K8s Tools
- Kubectl (Including bash completion)
- Flux (Including bash completion)
- Helm (Including bash completion)

## How to use with [docker-compose](docker-compose.example.yaml)
1) `docker compose run app`
2) `cd /mnt`
3) Do stuff