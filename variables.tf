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

# Chaves SSH autorizadas (pública(s) para login). Obrigatória para acesso SSH.
variable "ssh_authorized_keys" {
  type        = string
  description = "Conteúdo da(s) chave(s) pública(s) (ex: id_ed25519.pub) a ser inserida em ~/.ssh/authorized_keys do usuario default (opc). Para múltiplas, separar por \n."
  # Sem default para forçar fornecimento via secret (TF_VAR_ssh_authorized_keys)
  validation {
    condition     = length(trimspace(var.ssh_authorized_keys)) > 0
    error_message = "Defina ao menos uma chave pública SSH em ssh_authorized_keys (via secret GitHub SSH_AUTHORIZED_KEYS)."
  }
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
