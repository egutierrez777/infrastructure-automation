# Kubernetes Platform on VMware vSphere

Automated deployment of a highly available Kubernetes cluster on VMware vSphere using Terraform and Ansible.

The project automates virtual machine provisioning, operating system configuration, Kubernetes cluster initialization, networking, load balancing and application deployment.

## Architecture

    VMware vSphere
          |
      Terraform
          |
       Ansible
          |
    +-----+---------------------+
    |                           |
    HAProxy              Kubernetes Cluster
    |                    3 Control Planes
    |                    2 Worker Nodes
    |                           |
    |                         Calico
    |                           |
    +-- HTTP :80                 |
    |                           |
    +-- Kubernetes API :6443     |
    |                           |
    v                           |
    Traefik NodePort              |
    |                           |
    Kubernetes Ingress            |
    |                           |
    Podinfo Service               |
    |                           |
    Podinfo Pods

## Virtual Infrastructure

| Virtual Machine | Role |
|---|---|
| `k8s-lb01` | HAProxy load balancer |
| `k8s-master01` | Initial Kubernetes control plane |
| `k8s-master02` | Additional control plane |
| `k8s-master03` | Additional control plane |
| `k8s-worker01` | Kubernetes worker |
| `k8s-worker02` | Kubernetes worker |

## Technology Stack

- **VMware vSphere** — virtualization platform.
- **Terraform** — infrastructure provisioning and Ansible orchestration.
- **Ansible** — operating system configuration and platform deployment.
- **Kubernetes** — container orchestration.
- **Calico** — container networking (CNI).
- **HAProxy** — Kubernetes API and HTTP traffic load balancing.
- **Helm** — Kubernetes application and chart management.
- **Traefik** — Kubernetes Ingress Controller.
- **Podinfo** — sample application deployed through Helm.

### Component Versions

| Component | Version |
|---|---|
| Terraform | `>= 1.10, < 2.0` |
| VMware vSphere provider | `~> 2.12` |
| Traefik Helm chart | `41.7.1` |
| Traefik application | `3.7.14` |
| Podinfo | `6.11.2` |

## Deployment Workflow

Terraform coordinates the deployment through Ansible playbooks and provisioners.

1. Provision six virtual machines on VMware vSphere.
2. Configure hostnames, networking and operating system prerequisites.
3. Configure HAProxy for the Kubernetes API and HTTP traffic.
4. Prepare the nodes and initialize the Kubernetes control plane.
5. Install Calico and join the additional control-plane nodes.
6. Join both worker nodes.
7. Install Helm and deploy Podinfo.
8. Install Traefik and configure the Podinfo Ingress.

The application deployment is defined in `ansible/playbooks/applications.yaml`, which executes the following roles in order:

1. `applications`
2. `traefik`
3. `podinfo_ingress`

Terraform orchestrates the workflow, while Ansible configures the Kubernetes platform and its applications.

## HTTP Application Publishing

Podinfo is published through HAProxy and Traefik using a Kubernetes Ingress resource.

    Client
      |
      | HTTP :80
      v
    HAProxy
      |
      | NodePort :30081
      v
    Traefik
      |
      v
    Kubernetes Ingress
      |
      v
    Podinfo Service
      |
      v
    Podinfo Pods

The application hostname is:

`podinfo.k8s.example.com`

### DNS Configuration

To access the application, the hostname `podinfo.k8s.example.com` must resolve to the IP address of the HAProxy load balancer.

This can be configured through a DNS record or, for testing purposes, by adding an entry to the client's `/etc/hosts` file on Linux.

### Access the Application

Once name resolution is configured, access the application at:

http://podinfo.k8s.example.com

The expected response is `HTTP 200 OK`.

HTTP access has been validated through HAProxy and directly through both worker nodes.

The Kubernetes API uses a separate HAProxy TCP frontend on port `6443`.

## Repository Structure

    kubernetes-platform/
    ├── ansible/
    │   ├── inventories/
    │   ├── playbooks/
    │   ├── roles/
    │   └── ansible.cfg
    ├── terraform/
    │   ├── modules/
    │   │   └── vm/
    │   ├── ansible.tf
    │   ├── inventory-bootstrap.tpl
    │   ├── inventory-kubernetes.tpl
    │   ├── inventory.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   └── versions.tf
    └── README.md

- `terraform/`: VMware vSphere resources, reusable VM module, inventory generation and Ansible orchestration.
- `ansible/playbooks/`: deployment stages for the infrastructure, Kubernetes and applications.
- `ansible/roles/`: reusable configuration roles and Jinja2 templates.
- `ansible/inventories/`: inventories used by the automation.

## Prerequisites

- VMware vSphere access and permissions to provision virtual machines.
- A compatible Ubuntu virtual machine template.
- Terraform `1.10` or later, within the supported major version range.
- Ansible and Git installed on the automation host.
- SSH connectivity to the provisioned machines.
- Configured vSphere credentials, network settings and infrastructure variables.

## Deployment

All Terraform commands must be executed from the `terraform/` directory.

From the repository root, enter the Terraform directory:

    cd terraform

### 1. Initialize Terraform

    terraform init

### 2. Validate the Configuration

    terraform fmt -check -recursive
    terraform validate

### 3. Review the Execution Plan

    terraform plan -out=tfplan

Review the proposed actions before proceeding. Check for unexpected virtual machine replacements or unnecessary execution of configuration stages.

### 4. Apply the Reviewed Plan

Only after reviewing the plan, execute:

    terraform apply tfplan

This applies the previously saved plan. If the configuration changes after the plan is generated, create and review a new plan before applying it.

Terraform orchestrates the configured Ansible playbooks as part of the deployment workflow.

Configure the required Terraform variables locally. Do not commit credentials or environment-specific secret files.

## Verification

### Verify Kubernetes from a Control Plane Node

Connect to a Kubernetes control plane node. The Kubernetes administrative configuration is located at `/etc/kubernetes/admin.conf`.

Use `sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf` to execute administrative Kubernetes commands.

Check the cluster nodes:

    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide

Check pods across all namespaces:

    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -A

Check the application resources:

    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods,services,ingress -n podinfo

Check Traefik resources:

    sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods,services -n traefik

These commands are intended to be run on a control plane node where the administrative kubeconfig exists and `kubectl` is installed.

### Verify HTTP Access

From a client with network access to the load balancer, test the published application:

    curl -sS -D - http://podinfo.k8s.example.com/

The hostname must resolve correctly for this test to succeed.

The expected response is `HTTP 200 OK`.

## Security
The current application endpoint uses HTTP. HTTPS and certificate management are not included in the current implementation.
