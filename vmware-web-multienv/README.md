# VMware Web Multi-Environment

Infrastructure as Code project for deploying and configuring multiple web environments on VMware vSphere using Terraform and Ansible.

The project implements three environments with different levels of complexity:

- **Development** — single NGINX web server
- **Staging** — HAProxy load balancer + single NGINX web server
- **Production** — HAProxy load balancer + multiple NGINX web servers

The main goal is to reproduce a realistic infrastructure lifecycle where development, staging, and production have progressively closer characteristics to a real production architecture.

## Architecture

The infrastructure runs on VMware vSphere.

Terraform is responsible for provisioning the virtual machines by cloning an existing VMware virtual machine template.

After the virtual machines are created, Terraform automatically generates the corresponding Ansible inventory and executes the appropriate Ansible playbook for the selected environment.

```text
                    VMware vSphere
                          │
                          │
                   Existing VM Template
                          │
             ┌────────────┴────────────┐
             │                         │
          Terraform                Ansible
             │                         │
       Clone VMs from             Configure VMs
       existing template          and services
             │                         │
             └────────────┬────────────┘
                          │
                    Environment
                          │
          ┌───────────────┼────────────────┐
          │               │                │
         DEV           STAGING            PROD
          │               │                │
       ┌──▼───┐       ┌───▼───┐       ┌───▼───┐
       │ Web  │       │HAProxy │       │HAProxy │
       │ NGINX│       └───┬───┘       └───┬───┘
       └──────┘           │               │
                       ┌──▼───┐      ┌────┴────┐
                       │ Web  │      │         │
                       │ NGINX│   ┌──▼───┐ ┌──▼───┐
                       └──────┘   │ Web01│ │ Web02│
                                  │ NGINX│ │ NGINX│
                                  └──────┘ └──────┘
```

Production web server count is configurable. Terraform creates the requested number of web servers and automatically adds them to the Ansible inventory.

## Environments

### Development

Development is intentionally simple and provides a single web server.

```text
        DEV
         │
     ┌───▼────┐
     │ Web01  │
     │ NGINX  │
     └────────┘
```

Terraform creates:

- 1 virtual machine
- NGINX web server

Ansible configures the web server and performs an HTTP health check after deployment.

This environment is intended for basic development and infrastructure testing.

### Staging

Staging introduces the load-balancing layer used in production, but at a smaller scale.

```text
              STAGING

             ┌─────────┐
             │ HAProxy │
             └────┬────┘
                  │
             ┌────▼────┐
             │  Web01  │
             │  NGINX  │
             └─────────┘
```

Terraform creates:

- 1 HAProxy virtual machine
- 1 NGINX virtual machine

HAProxy receives HTTP traffic and forwards it to the web server.

This environment is designed to validate the production architecture before promoting changes to production.

### Production

Production implements a simple high-availability web architecture with a load balancer and multiple web servers.

```text
                  PROD

               ┌─────────┐
               │ HAProxy │
               └────┬────┘
                    │
             Round-robin
                    │
          ┌─────────┴─────────┐
          │                   │
      ┌───▼────┐          ┌───▼────┐
      │ Web01  │          │ Web02  │
      │ NGINX  │          │ NGINX  │
      └────────┘          └─────────┘
```

The number of web servers is controlled by Terraform.

For example, if the production configuration requests two web servers, Terraform creates:

```text
HAProxy
   │
   ├── Web01
   └── Web02
```

The same architecture can be expanded by increasing the number of web server instances.

## Technology Stack

| Technology | Purpose |
|---|---|
| VMware vSphere | Virtualization platform |
| Terraform | Infrastructure provisioning |
| Ansible | Configuration management |
| NGINX | Web server |
| HAProxy | HTTP load balancing |
| OpenSSH | VM connectivity |
| Ubuntu | Guest operating system |

The virtual machines are created by cloning an existing VMware vSphere template rather than installing the operating system from scratch.

## Terraform

Terraform provides the infrastructure provisioning layer.

A reusable VM module is used by all environments:

```text
terraform/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
│
└── modules/
    └── vm/
```

The VM module retrieves the existing vSphere resources and template:

```text
vSphere Datacenter
       │
       ├── ESXi Host
       ├── Datastore
       ├── Network
       └── VM Template
```

The module then clones the template to create the required virtual machines.

The environments reuse the same module while defining their own topology.

### Environment topology

#### DEV

```text
module "web01"
        │
        └── VM
```

#### STAGING

```text
module "lb01"
        │
        └── HAProxy VM

module "web01"
        │
        └── NGINX VM
```

#### PROD

```text
module "lb01"
        │
        └── HAProxy VM

module "web"
        │
        ├── Web01
        ├── Web02
        └── ...
```

This keeps the infrastructure definition reusable while allowing each environment to have its own architecture.

## Automatic Ansible Integration

Terraform also handles the transition from infrastructure provisioning to configuration management.

After creating the virtual machines, Terraform generates an Ansible inventory using the VM names and IP addresses returned by the vSphere provider.

The generated inventories are environment-specific:

```text
ansible/
└── inventories/
    ├── dev/
    │   └── hosts.ini
    ├── staging/
    │   └── hosts.ini
    └── prod/
        └── hosts.ini
```

Terraform then automatically executes the corresponding Ansible playbook.

For example:

```text
Terraform
    │
    ├── Create VMs
    │
    ├── Obtain VM IP addresses
    │
    ├── Generate inventory
    │
    └── Execute:
            ansible-playbook
                    │
                    └── playbooks/main.yaml
```

Production inventories are generated dynamically from all web servers created by Terraform.

This means that adding another web server does not require manually editing the Ansible inventory.

## Ansible

Ansible is responsible for configuring the operating system and application services.

The playbook separates responsibilities by host group:

```yaml
- name: Configure web server
  hosts: webservers

- name: Configure load balancer
  hosts: loadbalancers
```

The roles are:

```text
ansible/
└── roles/
    ├── webserver/
    └── loadbalancer/
```

### Webserver role

The webserver role:

- Configures the hostname
- Gathers system facts
- Installs NGINX
- Configures NGINX
- Deploys the web page
- Starts and enables the NGINX service
- Restarts NGINX when configuration changes
- Performs an HTTP health check
- Validates that the returned content is not empty

The generated page displays information about the server, including:

- Environment
- Server
- Hostname
- IP Address
- Operating System

This makes it easy to visually identify which backend is responding when testing the load balancer.

## HAProxy

The load balancer role installs and configures HAProxy.

HAProxy listens on HTTP port 80 and forwards traffic to the servers in the Ansible `webservers` group.

The backend configuration is generated dynamically:

```text
HAProxy
   │
   └── web_servers
          │
          ├── Web01:80
          ├── Web02:80
          └── WebN:80
```

The load-balancing algorithm is:

```text
roundrobin
```

Backend servers are also configured with health checks:

```text
server <webserver> <ip>:80 check
```

The Ansible role validates the HAProxy configuration before applying it and performs an HTTP health check after deployment.

## Deployment Flow

The complete deployment process is:

```text
1. Select environment
        │
        ▼
2. Terraform reads vSphere configuration
        │
        ▼
3. Terraform locates existing VM template
        │
        ▼
4. Terraform clones required virtual machines
        │
        ▼
5. Terraform obtains VM IP addresses
        │
        ▼
6. Terraform generates Ansible inventory
        │
        ▼
7. Terraform executes Ansible
        │
        ▼
8. Ansible installs and configures services
        │
        ├── NGINX
        │
        └── HAProxy
        │
        ▼
9. Application/load-balancer health checks
        │
        ▼
10. Environment ready
```

This creates a single automated workflow from infrastructure provisioning to service configuration and basic validation.

## Project Structure

```text
vmware-web-multienv/
│
├── ansible/
│   ├── ansible.cfg
│   ├── group_vars/
│   ├── inventories/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── playbooks/
│   │   └── main.yaml
│   └── roles/
│       ├── loadbalancer/
│       └── webserver/
│
└── terraform/
    ├── environments/
    │   ├── dev/
    │   ├── staging/
    │   └── prod/
    │
    └── modules/
        └── vm/
```

The separation between environments and reusable modules makes it possible to evolve each environment independently without duplicating the VM provisioning logic.

## Requirements

The deployment environment requires:

- VMware vSphere infrastructure
- An existing VM template
- Terraform >= 1.10, < 2.0
- VMware vSphere Terraform provider ~> 2.12
- Ansible
- SSH access to the provisioned VMs
- Ansible user with sudo privileges
- Python 3 on the target VMs

The virtual machines are provisioned from the existing vSphere template, so the template must already be available in the target vSphere environment.

## Deployment

Each environment is managed independently from its corresponding Terraform directory.

### Development

```bash
cd terraform/environments/dev

terraform init
terraform plan
terraform apply
```

### Staging

```bash
cd terraform/environments/staging

terraform init
terraform plan
terraform apply
```

### Production

```bash
cd terraform/environments/prod

terraform init
terraform plan
terraform apply
```

Terraform will provision the required infrastructure, generate the environment-specific Ansible inventory, and execute the corresponding Ansible playbook.

## Validation

After deployment, the infrastructure can be validated from several layers.

### Infrastructure

Verify the Terraform outputs:

```bash
terraform output
```

### Ansible

Verify that the playbook completes successfully:

```bash
ansible-playbook \
  -i ../../../ansible/inventories/prod/hosts.ini \
  ../../../ansible/playbooks/main.yaml
```

### Web server

The webserver role performs an HTTP health check against the local NGINX instance.

### Load balancer

The HAProxy role validates its configuration before restarting the service and performs an HTTP health check after deployment.

In production, repeated requests through HAProxy can be used to demonstrate traffic distribution between the backend web servers.

## Security Considerations

Sensitive Terraform variables such as vSphere credentials are intentionally kept outside the repository through environment-specific variable files and Git ignore rules.

The repository should never contain:

- vSphere passwords
- Private SSH keys
- Terraform state files
- Production credentials
- `.env` files

The infrastructure is intended for a controlled VMware lab environment and should be adapted before being used in a production environment with real credentials and security requirements.

## Key Infrastructure Concepts Demonstrated

This project demonstrates several practical infrastructure and DevOps concepts:

- Infrastructure as Code with Terraform
- VMware vSphere automation
- Reusable Terraform modules
- Multi-environment infrastructure
- Environment-specific Terraform configurations
- VM cloning from a reusable template
- Automatic Ansible inventory generation
- Terraform and Ansible integration
- Configuration management with Ansible
- NGINX automation
- HAProxy configuration
- HTTP load balancing
- Round-robin traffic distribution
- Backend health checks
- Infrastructure validation
- Basic web service health checks
- Production-oriented environment separation
- Horizontal scaling of web servers

## Project Objective

The project was built to simulate a realistic infrastructure lifecycle:

```text
Development
     │
     ▼
  Staging
     │
     ▼
 Production
```

Development provides a simple environment for application and infrastructure changes.

Staging reproduces the production architecture on a smaller scale, allowing infrastructure changes to be validated before reaching production.

Production introduces multiple web servers behind HAProxy, providing a foundation for horizontal scaling and high availability at the web tier.

The project therefore focuses not only on provisioning virtual machines, but on demonstrating how infrastructure, configuration management, service deployment, load balancing, and validation can be integrated into a repeatable workflow.
