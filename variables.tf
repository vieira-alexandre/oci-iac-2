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

variable "backend_bucket" {
  type        = string
  description = "Nome do bucket Object Storage (compatível S3) que armazenará o terraform state."
}
variable "backend_state_key" {
  type        = string
  description = "Caminho/arquivo da chave de state dentro do bucket (ex: terraform/oci-iac/terraform.tfstate)."
  default     = "terraform/oci-iac/terraform.tfstate"
}
variable "s3_access_key" {
  type        = string
  description = "Access key para endpoint S3 compatível (OCI Object Storage)."
}
variable "s3_secret_key" {
  type        = string
  description = "Secret key para endpoint S3 compatível (OCI Object Storage)."
  sensitive   = true
}
variable "s3_endpoint" {
  type        = string
  description = "Endpoint HTTPS do serviço Object Storage compatível S3 na região (ex: https://<namespace>.compat.objectstorage.<region>.oraclecloud.com)."
}
variable "backend_encrypt" {
  type        = bool
  description = "Se o backend deve marcar encrypt=true (geralmente sim)."
  default     = true
}
