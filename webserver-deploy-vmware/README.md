# VMware Web Server Deployment with Terraform and Ansible

This project automates the deployment of an Ubuntu virtual machine on VMware vSphere using Terraform and configures a web server using Ansible.

## Overview

Deployment workflow:
Terraform → VMware vSphere → Ubuntu VM → Ansible → NGINX

Terraform is responsible for:

- Creating the virtual machine from a VMware template.
- Generating the Ansible inventory.

Ansible is responsible for:

- Configuring the server.
- Installing NGINX.
- Deploying a custom web page using Jinja2 templates.

## Project Structure
webserver-deploy-vmware/
│
├── terraform-vsphere-lab-standalone/
│ ├── main.tf
│ ├── providers.tf
│ └── variables.tf
│
└── ansible-webserver-standalone/
├── main.yml
├── group_vars/
└── roles/
└── webserver/

## Requirements

- VMware vSphere / ESXi
- Ubuntu VM template
- Terraform
- Ansible
- SSH key authentication configured

## Deployment

### Create the VM

```bash
cd terraform-vsphere-lab-standalone

terraform init
terraform plan
terraform apply
```

### Technologies
- Terraform
- Ansible
- VMware vSphere
- Ubuntu
- NGINX
