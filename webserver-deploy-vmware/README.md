# VMware Web Server Deployment with Terraform and Ansible

Simple Infrastructure as Code project for deploying a standalone Ubuntu web server on VMware vSphere using Terraform and configuring it with Ansible.

The project combines Terraform for infrastructure provisioning and Ansible for operating system and web server configuration.

## Overview

The deployment workflow is:

    Terraform
        │
        ▼
    VMware vSphere
        │
        ▼
    Ubuntu VM cloned from template
        │
        ▼
    Ansible inventory generated
        │
        ▼
    Ansible playbook executed
        │
        ▼
    NGINX installed and configured
        │
        ▼
    Web page deployed

Terraform is responsible for:

- Connecting to VMware vSphere.
- Locating the existing Ubuntu VM template.
- Cloning the virtual machine.
- Obtaining the VM IP address.
- Generating the Ansible inventory.
- Executing the Ansible playbook.

Ansible is responsible for:

- Installing NGINX.
- Starting and enabling the NGINX service.
- Deploying the web page.
- Restarting NGINX when the page configuration changes.

## Architecture

The project deploys a single standalone web server.

    VMware vSphere
          │
          │
    Existing VM Template
          │
          ▼
    ┌─────────────────┐
    │    Terraform    │
    │                 │
    │  Clone VM       │
    │  Get IP         │
    │  Generate       │
    │  inventory      │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │    Ubuntu VM    │
    │                 │
    │      NGINX      │
    └────────┬────────┘
             │
             │ SSH
             ▼
    ┌─────────────────┐
    │     Ansible     │
    │                 │
    │ Install NGINX   │
    │ Start service   │
    │ Deploy webpage  │
    └─────────────────┘

The virtual machine is not installed from an operating system ISO. Terraform clones an existing VMware vSphere virtual machine template and uses the template as the base for the new server.

## Terraform

Terraform provides the infrastructure provisioning layer.

The configuration retrieves the existing vSphere resources required for the deployment:

    vSphere
       │
       ├── Datacenter
       │
       ├── ESXi Host
       │
       ├── Datastore
       │
       ├── Network
       │
       └── Existing VM Template

The VM is then cloned from the existing template.

The deployed virtual machine is configured with:

- 2 vCPUs.
- 4096 MB of memory.
- A network interface based on the template.
- A disk based on the template disk size.
- Thin provisioning.
- The guest configuration inherited from the template.

The project uses the VMware vSphere Terraform provider.

## VM Cloning

Terraform uses an existing VMware template as the source of the virtual machine.

    Existing Template
    lab-ubuntu26-template
            │
            │ Terraform clone
            ▼
    lab-ubuntu-server
            │
            ▼
    Ubuntu Web Server

The Terraform configuration retrieves the template from vSphere and uses its UUID when creating the new virtual machine.

This allows the operating system and base VM configuration to be prepared beforehand in the template.

## Automatic Ansible Inventory

Terraform generates the Ansible inventory after the virtual machine has been created.

The inventory is generated using the IP address returned by the vSphere provider.

    Terraform
        │
        ├── Create VM
        │
        ├── Obtain VM IP
        │
        └── Generate
            ansible-webserver-standalone/inventory/hosts.ini

The generated inventory contains a single `webserver` host.

It also defines the connection and privilege escalation settings required by Ansible.

This removes the need to manually configure the VM IP address in the Ansible inventory after deployment.

## Automatic Ansible Execution

Terraform automatically executes the Ansible playbook after the VM and inventory have been created.

The dependency chain is:

    vsphere_virtual_machine
            │
            ▼
    local_file inventory
            │
            ▼
    null_resource
            │
            ▼
    ansible-playbook
            │
            ▼
    NGINX configuration

The Ansible execution depends on both the virtual machine and the generated inventory.

The Terraform `null_resource` also tracks changes to the VM and inventory so that the configuration step can be triggered when the relevant infrastructure changes.

## Ansible

Ansible is responsible for configuring the web server.

The main playbook targets the `webserver` inventory group and applies the `webserver` role.

The playbook uses privilege escalation because NGINX installation and configuration require administrative privileges.

The Ansible structure separates the playbook from the reusable web server role.

## Webserver Role

The `webserver` role performs the basic web server configuration.

The role:

- Installs NGINX.
- Starts the NGINX service.
- Enables NGINX to start automatically.
- Deploys the web page.
- Restarts NGINX when the page template changes.

The configuration flow is:

    Ansible
       │
       ▼
    Install NGINX
       │
       ▼
    Start and enable NGINX
       │
       ▼
    Deploy index.html
       │
       ▼
    Configuration changed?
       │
       └── Yes ──► Restart NGINX

The NGINX restart is handled through an Ansible handler.

## Web Page

The web page is generated using a Jinja2 template.

The template uses Ansible variables and facts to display information about the deployed server.

The page includes:

- Server name.
- Server IP address.
- Operating system.
- Operating system version.

It also indicates that the page was generated automatically by Ansible.

Example output:

    Web server deployed with Ansible

    Server: <hostname>
    IP Address: <server-ip>
    Operating System: <distribution> <version>

    THIS WEB PAGE WAS GENERATED AUTOMATICALLY BY ANSIBLE

This provides a simple way to verify that the server is correctly configured and that NGINX is serving the expected content.

## Project Structure

    webserver-deploy-vmware/
    │
    ├── README.md
    │
    ├── terraform-vsphere-lab-standalone/
    │   ├── main.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── terraform.tfvars
    │   └── terraform.tfstate
    │
    └── ansible-webserver-standalone/
        ├── group_vars/
        │   └── all.yml
        │
        ├── inventory/
        │   └── hosts.ini
        │
        ├── main.yml
        │
        └── roles/
            └── webserver/
                ├── defaults/
                │   └── all.yml
                ├── handlers/
                │   └── main.yml
                ├── tasks/
                │   └── main.yml
                └── templates/
                    └── index.html.j2

The `hosts.ini` file is generated automatically by Terraform during deployment.

## Deployment Flow

The complete deployment process is:

    1. Terraform initialization
               │
               ▼
    2. Connect to VMware vSphere
               │
               ▼
    3. Locate existing VM template
               │
               ▼
    4. Clone Ubuntu VM
               │
               ▼
    5. Obtain VM IP address
               │
               ▼
    6. Generate Ansible inventory
               │
               ▼
    7. Execute Ansible playbook
               │
               ▼
    8. Install NGINX
               │
               ▼
    9. Start and enable NGINX
               │
               ▼
    10. Deploy web page
               │
               ▼
    11. Restart NGINX if required

The result is a standalone Ubuntu web server running NGINX and serving a dynamically generated web page.

## Requirements

The deployment requires:

- VMware vSphere / ESXi.
- An existing Ubuntu VM template.
- Terraform.
- Ansible.
- SSH access to the provisioned VM.
- An Ansible user with the required sudo privileges.

The virtual machine is provisioned from an existing vSphere template, so the template must already be available in the target VMware environment.

## Terraform Provider

The project uses the VMware vSphere Terraform provider.

The provider is responsible for connecting Terraform to the VMware vSphere environment.

The project currently uses the `hashicorp/vsphere` provider in the `~> 2.7` version range.

## Deployment

Move into the Terraform project:

    cd terraform-vsphere-lab-standalone

Initialize Terraform:

    terraform init

Review the planned infrastructure:

    terraform plan

Apply the configuration:

    terraform apply

During `terraform apply`, Terraform:

1. Connects to VMware vSphere.
2. Locates the existing VM template.
3. Creates the virtual machine.
4. Obtains the VM IP address.
5. Generates the Ansible inventory.
6. Executes the Ansible playbook.
7. Configures NGINX.
8. Deploys the web page.

## Validation

After deployment completes, the web server can be validated by accessing the IP address assigned to the virtual machine.

The expected result is the web page generated by the Ansible Jinja2 template.

The page should display information such as:

    Server
    IP Address
    Operating System
    Operating System Version

The NGINX service can also be checked directly on the VM:

    systemctl status nginx

The Ansible configuration confirms that NGINX has been installed, started, and configured with the generated web page.

## Security Considerations

The project requires credentials to connect Terraform to VMware vSphere and uses SSH to connect Ansible to the provisioned VM.

Sensitive credentials and private keys should not be committed to the repository.

The repository should not contain:

- vSphere passwords.
- Private SSH keys.
- Production credentials.
- Terraform state files containing sensitive information.
- Local environment files.

The project is intended for a controlled VMware lab environment and should be adapted appropriately before being used in a production environment.

## Technologies

| Technology | Purpose |
|---|---|
| VMware vSphere | Virtualization platform |
| Terraform | Infrastructure provisioning |
| Ansible | Configuration management |
| Ubuntu | Guest operating system |
| NGINX | Web server |
| Jinja2 | Dynamic web page templating |
| OpenSSH | Remote server connectivity |

## Project Objective

This project demonstrates a simple Infrastructure as Code workflow combining Terraform and Ansible.

Terraform handles the infrastructure layer by cloning an existing Ubuntu VM template and preparing the newly created virtual machine.

Ansible handles the configuration layer by installing NGINX, managing the service, and deploying a dynamic web page.

The complete workflow is automated so that a single Terraform deployment can create the virtual machine and continue with its configuration through Ansible.
