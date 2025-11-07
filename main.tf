terraform {
  required_version = ">= 1.6.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
  # Backend remoto em OCI Object Storage via API compatível S3.
  # Credenciais e detalhes (endpoint, bucket, chave, access_key, secret_key) NÃO ficam hardcoded aqui;
  # são passados no comando terraform init com -backend-config=...
  # Mantemos bloco vazio para habilitar backend e permitir sobrescrever via CLI.
  backend "s3" {}
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
  # Referências para backend (usado externamente via -backend-config, mantidas para evitar warnings de variáveis não usadas)
  _backend_bucket       = var.backend_bucket
  _backend_state_key    = var.backend_state_key
  _backend_s3_endpoint  = var.s3_endpoint
  _backend_s3_access    = var.s3_access_key
  _backend_s3_secret    = var.s3_secret_key
  _backend_encrypt_flag = var.backend_encrypt
}

module "network" {
  source             = "./modules/network"
  compartment_ocid   = var.compartment_ocid
  vcn_cidr           = var.vcn_cidr
  public_subnet_cidr = var.public_subnet_cidr
  dns_label_prefix   = local.prefix
}

# module "compute" {
#   source                         = "./modules/compute"
#   compartment_ocid               = var.compartment_ocid
#   subnet_id                      = module.network.public_subnet_id
#   instance_shape                 = var.instance_shape
#   ocpus                          = var.instance_ocpus
#   memory_in_gbs                  = var.instance_memory_gbs
#   instance_display_name          = "${local.prefix}-vm01"
#   image_operating_system         = var.image_operating_system
#   image_operating_system_version = var.image_operating_system_version
# }
