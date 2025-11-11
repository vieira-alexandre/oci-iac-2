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

locals {
  prefix = var.project_prefix
}

module "nextcloud-network" {
  source             = "./modules/network"
  compartment_ocid   = var.compartment_ocid
  vcn_cidr           = var.vcn_cidr
  public_subnet_cidr = var.public_subnet_cidr
  dns_label_prefix   = local.prefix
}

# module "vm-amd" {
#   source                         = "./modules/compute"
#   compartment_ocid               = var.compartment_ocid
#   subnet_id                      = module.network-1.public_subnet_id
#   instance_shape                 = "VM.Standard.E2.1.Micro"
#   ocpus                          = 1
#   memory_in_gbs                  = 1
#   instance_display_name          = "${local.prefix}-amd-vm"
#   image_operating_system         = "Canonical Ubuntu"
#   image_operating_system_version = "24.04"
#   image_id                       = var.image_id
#   boot_volume_size_gbs           = null
#   ssh_authorized_keys            = var.ssh_authorized_keys
#   network_security_group_ids     = [module.network-1.db_nsg_id]
# }
#
# module "vm-amd-db" {
#   source                         = "./modules/compute"
#   compartment_ocid               = var.compartment_ocid
#   subnet_id                      = module.network-1.public_subnet_id
#   instance_shape                 = "VM.Standard.E2.1.Micro"
#   ocpus                          = 1
#   memory_in_gbs                  = 1
#   instance_display_name          = "${local.prefix}-vm-amd-db"
#   image_operating_system         = "Canonical Ubuntu"
#   image_operating_system_version = "24.04"
#   image_id                       = var.image_id
#   boot_volume_size_gbs           = null
#   ssh_authorized_keys            = var.ssh_authorized_keys
#   network_security_group_ids     = [module.network-1.db_nsg_id]
# }

# resource "oci_core_network_security_group_security_rule" "db_mysql_ingress" {
#   network_security_group_id = module.network-1.db_nsg_id
#   direction                 = "INGRESS"
#   protocol                  = "6"
#   source_type               = "CIDR_BLOCK"
#   source                    = "${module.vm-amd.private_ip}/32"
#   description               = "Permitir MySQL apenas da vm-amd"
#   tcp_options {
#     destination_port_range {
#       min = 3306
#       max = 3306
#     }
#   }
# }
