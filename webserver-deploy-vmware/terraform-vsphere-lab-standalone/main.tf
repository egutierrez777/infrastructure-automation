data "vsphere_datacenter" "dc" {
  name = "DatacenterLegacy"
}

data "vsphere_host" "host" {
  name          = "172.22.12.40"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "DS3PAR-LAB"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "Dimanet"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "lab-ubuntu26-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "ubuntu" {
  name              = "lab-ubuntu-server"
  resource_pool_id  = data.vsphere_host.host.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id
  num_cpus          = 2
  memory            = 4096
  guest_id          = data.vsphere_virtual_machine.template.guest_id
  scsi_type         = data.vsphere_virtual_machine.template.scsi_type
  
  network_interface {
    network_id    = data.vsphere_network.network.id
    adapter_type  = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label             = "disk0"
    size              = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned  = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}

resource "local_file" "inventory" {
  filename  = "../ansible-webserver-standalone/inventory/hosts.ini"
  content   = <<-EOF
    [webserver]
    ${vsphere_virtual_machine.ubuntu.default_ip_address}

    [webserver:vars]
    ansible_user=ansible
    ansible_ssh_private_key_file=~/.ssh/id_ed25519
    ansible_become=true
    ansible_become_method=sudo
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
  EOF
}

resource "null_resource" "configure_vm" {
  depends_on  = [
    vsphere_virtual_machine.ubuntu,
    local_file.inventory
  ]

  triggers = {
    vm_id   = vsphere_virtual_machine.ubuntu.id
    inventory = local_file.inventory.content_sha1
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible-webserver-standalone/inventory/hosts.ini ../ansible-webserver-standalone/main.yml"
  }
}
