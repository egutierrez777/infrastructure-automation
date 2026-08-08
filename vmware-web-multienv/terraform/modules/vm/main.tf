resource "vsphere_virtual_machine" "vm" {
  name              = var.vm_name
  resource_pool_id  = data.vsphere_host.host.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id

  num_cpus  = var.cpu
  memory    = var.memory

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
