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

module "network" {
  source             = "./modules/network"
  compartment_ocid   = var.compartment_ocid
  vcn_cidr           = var.vcn_cidr
  public_subnet_cidr = var.public_subnet_cidr
  dns_label_prefix   = local.prefix
}

module "compute" {
  source                         = "./modules/compute"
  compartment_ocid               = var.compartment_ocid
  subnet_id                      = module.network.public_subnet_id
  instance_shape                 = var.instance_shape
  ocpus                          = var.instance_ocpus
  memory_in_gbs                  = var.instance_memory_gbs
  instance_display_name          = "${local.prefix}-webserver-bolao"
  image_operating_system         = var.image_operating_system
  image_operating_system_version = var.image_operating_system_version
  image_id                       = var.image_id
}
