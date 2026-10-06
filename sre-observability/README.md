# SRE Observability Platform

Infrastructure-as-Code project for deploying a complete SRE observability stack on VMware vSphere.

The project provisions virtual machines with Terraform and configures the operating system and observability platform with Ansible.

The goal is to provide a reproducible environment for monitoring, SLOs, error-budget tracking and alerting.

---

## Architecture

The platform is composed of two virtual machines:

```text
                         VMware vSphere
                               |
              +----------------+----------------+
              |                                 |
              v                                 v
       +-------------+                   +---------------+
       | Web Server  |                   |  Monitoring   |
       | Ubuntu 26.04|                   | Ubuntu 26.04  |
       +-------------+                   +---------------+
              |                                 |
              | Node Exporter                   |
              | Application metrics             |
              |                                 |
              +--------------------+------------+
                                   |
                                   v
                              Prometheus
                                   |
                    +--------------+--------------+
                    |                             |
                    v                             v
                 Grafana                    Alertmanager
                                                  |
                                                  v
                                           Alert Webhook
```

---

## Components

### Infrastructure

- VMware vSphere
- Terraform
- Terraform VM module
- Existing Ubuntu 26.04 VM template

### Configuration Management

- Ansible
- Ansible roles
- Jinja2 templates

### Observability

- Prometheus
- Node Exporter
- Grafana
- Alertmanager
- Custom Python webhook

### SRE capabilities

- HTTP availability SLI
- HTTP latency SLI
- Availability SLO
- Error-budget burn rate
- 5-minute burn-rate window
- 1-hour burn-rate window
- Prometheus alerting rules
- Alertmanager notifications
- Alert lifecycle testing

---

## Infrastructure Provisioning

Terraform is responsible for creating the virtual machines on VMware vSphere.

The project does not install an operating system from scratch.

Instead, Terraform clones an existing Ubuntu 26.04 template and uses it as the base image for the required virtual machines.

Two virtual machines are created:

- `web` - application/web server
- `monitoring` - observability and monitoring server

Both machines are created using the reusable Terraform VM module.

```text
Terraform
   |
   +-- VM module
   |      |
   |      +-- Clone Ubuntu 26.04 template
   |      +-- Configure CPU
   |      +-- Configure memory
   |      +-- Configure network
   |      +-- Configure datastore
   |      +-- Configure vSphere host
   |
   +-- Web VM
   |
   +-- Monitoring VM
```

---

## Terraform

The main Terraform configuration creates two instances of the reusable VM module.

```hcl
module "web" {
  source = "./modules/vm"

  name   = var.name
  cpu    = var.cpu
  memory = var.memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}

module "monitoring" {
  source = "./modules/vm"

  name   = var.mon_name
  cpu    = var.mon_cpu
  memory = var.mon_memory

  datacenter = var.datacenter
  host       = var.host
  datastore  = var.datastore
  network    = var.network
  template   = var.template
}
```

The VM implementation is encapsulated inside:

```text
terraform/modules/vm/
```

This keeps the infrastructure reusable and avoids duplicating VM provisioning logic.

---

## Terraform → Ansible Integration

After Terraform creates the infrastructure, it generates the Ansible inventory and triggers the Ansible playbook.

```text
Terraform
    |
    |-- Create Web VM
    |
    |-- Create Monitoring VM
    |
    |-- Generate Ansible inventory
    |
    +--------------------+
                         |
                         v
                    Ansible
                         |
             +-----------+-----------+
             |                       |
             v                       v
        Web Server              Monitoring
             |                       |
             |                       +-- Prometheus
             |                       +-- Grafana
             |                       +-- Alertmanager
             |                       +-- Alert Webhook
             |
             +-- Node Exporter
```

The Terraform integration is implemented through a `terraform_data` resource:

```hcl
resource "terraform_data" "ansible" {
  depends_on = [
    local_file.ansible_inventory
  ]

  triggers_replace = [
    local_file.ansible_inventory.content
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/../ansible"

    command = <<-EOT
      ansible-playbook -i inventories/prod/hosts.ini playbooks/main.yaml
    EOT
  }
}
```

This allows the infrastructure provisioning and configuration management stages to be executed as part of the same workflow.

---

## Ansible

Ansible configures the two servers after they have been provisioned.

### Web server

The web server receives:

- Application
- Nginx
- Node Exporter
- systemd service configuration

### Monitoring server

The monitoring server receives:

- Prometheus
- Grafana
- Alertmanager
- Custom alert webhook

The main playbook is structured as:

```yaml
- name: Configure web server
  hosts: webservers
  become: true

  roles:
    - webserver
    - node_exporter

- name: Configure monitoring server
  hosts: monitoring
  become: true

  roles:
    - prometheus
    - grafana
    - alertmanager
    - alert-webhook
```

---

## Observability Architecture

The web application exposes Prometheus-compatible metrics.

Node Exporter exposes host-level system metrics.

Prometheus collects both application and infrastructure metrics.

```text
                    Web Application
                          |
                          | HTTP metrics
                          v
                    Node Exporter
                          |
                          |
                          v
                     Prometheus
                    /     |      \
                   /      |       \
                  v       v        v
             SLI/SLO   Alerts   Metrics
                         |
                         v
                    Alertmanager
                         |
                         v
                   Alert Webhook
```

Grafana uses Prometheus as its datasource for dashboards and SRE visibility.

---

## SLI / SLO

The project implements an availability SLI based on successful HTTP requests.

Successful requests are defined as HTTP `2xx` responses.

```promql
sum(rate(http_requests_total{status=~"2.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

The availability SLO is defined as:

```text
99% availability
1% error budget
```

The project also calculates an HTTP latency SLI for requests completed under 500 ms.

```promql
sum(
  rate(http_request_duration_seconds_bucket{le="0.5"}[5m])
)
/
sum(
  rate(http_request_duration_seconds_count[5m])
)
```

---

## Error Budget Burn Rate

The project calculates error-budget burn rate using both short and long observation windows.

### 5-minute burn rate

```promql
(1 - sli:http_availability:ratio5m) / 0.01
```

### 1-hour burn rate

```promql
(
  1 -
  (
    sum(rate(http_requests_total{status=~"2.."}[1h]))
    /
    sum(rate(http_requests_total[1h]))
  )
) / 0.01
```

A burn rate of:

```text
1x
```

means the service is consuming the error budget at the allowed rate.

A burn rate of:

```text
5x
```

means the service is consuming the error budget five times faster than the allowed rate.

---

## Alerting

The project contains Prometheus alert rules based on the SLO burn rate.

The high burn-rate alert evaluates both the short and long observation windows.

Example condition:

```promql
slo:http_availability:burn_rate5m > 5
and
slo:http_availability:burn_rate1h > 5
```

This avoids triggering an alert from a very short-lived spike alone.

The alert is configured with a pending period before transitioning to `firing`.

```text
Prometheus
    |
    | condition detected
    v
 PENDING
    |
    | condition remains true
    v
 FIRING
    |
    v
Alertmanager
    |
    v
Webhook
```

---

## Alert Lifecycle Testing

The project was tested using a realistic failure scenario instead of only checking static configuration.

The test flow was:

```text
Normal traffic
     |
     v
Availability = 100%
     |
     v
Burn rate = 0
     |
     v
Inject HTTP failures
     |
     v
Burn rate increases
     |
     v
Prometheus alert = pending
     |
     v
Prometheus alert = firing
     |
     v
Alertmanager receives alert
     |
     v
Webhook receives "firing"
     |
     v
Recover application
     |
     v
Burn rate returns to normal
     |
     v
Alert resolves
     |
     v
Webhook receives "resolved"
```

The webhook logs demonstrated both sides of the alert lifecycle:

```text
ALERT RECEIVED
status=firing
alertname=HighErrorBudgetBurnRate
severity=critical
```

and later:

```text
ALERT RECEIVED
status=resolved
alertname=HighErrorBudgetBurnRate
severity=critical
```

This validates the complete path from metric collection to alert recovery.

---

## Failure Scenario

During testing, the application was intentionally placed into an unhealthy state generating HTTP 500 responses.

Prometheus observed the increase in failed requests and calculated a high error-budget burn rate.

Example observed values:

```text
5m burn rate ≈ 100x
1h burn rate ≈ 99x
```

The alert transitioned through:

```text
pending → firing
```

and Alertmanager received the active alert.

After the application recovered, the burn rate returned to:

```text
0
```

and the alert disappeared from the active alert set.

Alertmanager subsequently delivered the resolved notification to the webhook.

---

## Project Structure

```text
sre-observability/
├── ansible/
│   ├── ansible.cfg
│   ├── inventories/
│   │   └── prod/
│   ├── playbooks/
│   │   └── main.yaml
│   └── roles/
│       ├── alertmanager/
│       ├── alert-webhook/
│       ├── grafana/
│       ├── node_exporter/
│       ├── prometheus/
│       └── webserver/
│
└── terraform/
    ├── modules/
    │   └── vm/
    ├── ansible.tf
    ├── inventory.tf
    ├── inventory.tpl
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    └── versions.tf
```

---

## Requirements

The project assumes an existing VMware vSphere environment with:

- vCenter
- Datacenter
- ESXi host
- Datastore
- Network
- Ubuntu 26.04 VM template

The automation host requires:

- Terraform
- Ansible
- SSH access to the provisioned VMs
- Access to the VMware vSphere API

The Ubuntu 26.04 template is used as the base image for both virtual machines.

---

## Configuration

Sensitive Terraform variables should be supplied locally and must not be committed to Git.

Example:

```text
terraform.tfvars
```

is intentionally ignored by Git.

A sanitized example can be provided as:

```text
terraform.tfvars.example
```

Example:

```hcl
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "CHANGE_ME"

datacenter = "DC01"
host       = "esxi01"
datastore  = "datastore01"
network    = "VM Network"
template   = "ubuntu-26.04-template"
```

Never commit:

```text
terraform.tfstate
terraform.tfstate.backup
terraform.tfvars
```

or private keys and credentials.

---

## Deployment

From the Terraform directory:

```bash
cd sre-observability/terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Terraform will:

1. Clone the Ubuntu 26.04 template.
2. Create the web server VM.
3. Create the monitoring VM.
4. Generate the Ansible inventory.
5. Execute the Ansible playbook.

---

## Validation

After deployment, validate the infrastructure:

```bash
terraform output
```

Validate Ansible:

```bash
cd ../ansible

ansible -i inventories/prod/hosts.ini all -m ping
```

Validate Prometheus:

```bash
curl http://<monitoring-ip>:9090/-/ready
```

Validate Alertmanager:

```bash
curl http://<monitoring-ip>:9093/-/ready
```

Validate the webhook service:

```bash
sudo systemctl status alert-webhook
```

---

## What This Project Demonstrates

This project demonstrates practical experience with:

- Infrastructure as Code
- Terraform modules
- VMware vSphere automation
- VM lifecycle automation
- Configuration management with Ansible
- Ansible role design
- Jinja2 templating
- Prometheus metrics
- PromQL
- SLI/SLO implementation
- Error-budget concepts
- Burn-rate alerting
- Grafana dashboards
- Alertmanager routing
- Webhook integrations
- Linux systemd services
- Failure injection
- Alert lifecycle testing
- Observability-driven troubleshooting

More importantly, the project demonstrates an end-to-end operational workflow:

```text
Infrastructure
      ↓
Configuration
      ↓
Application
      ↓
Metrics
      ↓
SLI
      ↓
SLO
      ↓
Error Budget
      ↓
Burn Rate
      ↓
Alert
      ↓
Alertmanager
      ↓
Notification
      ↓
Recovery
      ↓
Resolved Alert
```

The objective is not simply to deploy monitoring tools, but to demonstrate how infrastructure automation and SRE practices can be combined into a reproducible operational platform.
