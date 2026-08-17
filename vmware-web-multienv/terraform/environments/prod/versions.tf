terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.12"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
