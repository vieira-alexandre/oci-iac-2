variable "tenancy_ocid" {
  type = string
}
variable "user_ocid" {
  type = string
}
variable "fingerprint" {
  type = string
}
variable "private_key" {
  type        = string
  sensitive   = true
  description = "Conteúdo completo da chave privada OCI (PEM), injetado via secret GitHub (ex: OCI_PRIVATE_KEY)."
}
variable "region" {
  type = string
}

variable "compartment_ocid" {
  type = string
}
variable "project_prefix" {
  type    = string
  default = "prod"
}

# Network variables
variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

# Compute variables
variable "instance_shape" {
  type    = string
  default = "VM.Standard.E2.1.Micro"
}
variable "instance_ocpus" {
  type    = number
  default = 1
}
variable "instance_memory_gbs" {
  type    = number
  default = 8
}
variable "image_operating_system" {
  type    = string
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  type    = string
  default = "9"
}

# Backend OCI Object Storage
variable "backend_bucket" {
  type        = string
  description = "Nome do bucket Object Storage que armazenará o terraform state."
}
variable "backend_state_key" {
  type        = string
  description = "Caminho relativo do arquivo de state dentro do bucket (ex: terraform/oci-iac/terraform.tfstate)."
}
# Namespace é automaticamente obtido (oci os ns get) no pipeline; manter opcional para uso manual.
variable "object_storage_namespace" {
  type        = string
  description = "Namespace do Object Storage (geralmente obtido via OCI CLI)."
}
