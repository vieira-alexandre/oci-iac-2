terraform {
  required_version = ">= 1.13.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
  # Backend remoto nativo OCI Object Storage. Parâmetros (bucket, namespace, region, auth, key) serão injetados via terraform init -backend-config.
  backend "oci" {}
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

# Naming helper
locals {
  prefix = var.project_prefix
}

module "network-1" {
  source             = "./modules/network"
  compartment_ocid   = var.compartment_ocid
  vcn_cidr           = var.vcn_cidr
  public_subnet_cidr = var.public_subnet_cidr
  dns_label_prefix   = local.prefix
}

module "vm-amd" {
  source                         = "./modules/compute"
  compartment_ocid               = var.compartment_ocid
  subnet_id                      = module.network-1.public_subnet_id
  instance_shape                 = "VM.Standard.E2.1.Micro"
  ocpus                          = 1
  memory_in_gbs                  = 1
  instance_display_name          = "${local.prefix}-amd-vm"
  image_operating_system         = "Canonical Ubuntu"
  image_operating_system_version = "24.04"
  image_id                       = var.image_id
  boot_volume_size_gbs           = null
  ssh_authorized_keys            = var.ssh_authorized_keys
}

# module "vm-arm" {
#   source                         = "./modules/compute"
#   compartment_ocid               = var.compartment_ocid
#   subnet_id                      = module.network-1.public_subnet_id
#   instance_shape                 = "VM.Standard.E2.1.Micro"
#   ocpus                          = 1
#   memory_in_gbs                  = 1
#   instance_display_name          = "${local.prefix}-amd-db-vm"
#   image_operating_system         = "Canonical Ubuntu"
#   image_operating_system_version = "24.04"
#   image_id                       = var.image_id
#   boot_volume_size_gbs           = null
#   ssh_authorized_keys            = var.ssh_authorized_keys
# }
