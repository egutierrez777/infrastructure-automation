# Infrastructure Automation

**Infrastructure as Code · Automation · DevOps · Kubernetes · Observability · SRE**

A collection of practical projects focused on automating infrastructure, deploying services, orchestrating containers and building reliable and observable platforms.

The repository brings together practical implementations covering different aspects of modern infrastructure engineering, automation and operations.

## Projects

### 01 · Web Server Deployment

**Terraform · Ansible · VMware vSphere · NGINX**

Automated provisioning and configuration of a standalone web server.

→ [`webserver-deploy-vmware`](./webserver-deploy-vmware)

### 02 · Multi-Environment Infrastructure

**Terraform · Ansible · HAProxy · NGINX**

Development, staging, and production environments with load balancing and scalable web servers.

→ [`vmware-web-multienv`](./vmware-web-multienv)

### 03 · SRE Observability Platform

**Terraform · Ansible · Prometheus · Grafana · Alertmanager**

SLIs, SLOs, error budgets, burn-rate alerting, notifications, and end-to-end alert recovery.

→ [`sre-observability`](./sre-observability)

### 04 · Kubernetes Platform

**Terraform · Ansible · VMware vSphere · Kubernetes · Calico · HAProxy · Helm · Traefik**

Automated provisioning of a six-VM Kubernetes cluster with three control-plane nodes and two worker nodes, including cluster initialization, networking, API load balancing, and HTTP application publishing.

Podinfo is deployed with Helm and exposed through Traefik Ingress and HAProxy, demonstrating end-to-end infrastructure and application automation.

→ [`kubernetes-platform`](./kubernetes-platform)

## Technology Areas

### Infrastructure & Automation

`VMware vSphere` · `Terraform` · `Ansible`

### Web Infrastructure & Load Balancing

`NGINX` · `HAProxy`

### Container Orchestration

`Kubernetes` · `Calico` · `Helm` · `Traefik` · `Podinfo`

### Observability & SRE

`Prometheus` · `Grafana` · `Alertmanager` · `PromQL` · `SLI/SLO`

## Repository Focus

```text
Infrastructure as Code
        ↓
Automation
        ↓
Service Deployment
        ↓
Container Orchestration
        ↓
Scalable Infrastructure
        ↓
Observability
        ↓
SRE Practices
```

## Goals

- Automate infrastructure provisioning and configuration.
- Apply reusable Infrastructure as Code practices.
- Deploy and operate services on virtualized infrastructure.
- Build and automate Kubernetes platforms.
- Implement load balancing and application publishing.
- Apply observability and Site Reliability Engineering principles.
