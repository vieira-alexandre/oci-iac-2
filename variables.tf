variable "tenancy_ocid" {
  type = string
}
variable "user_ocid" {
  type = string
}
variable "fingerprint" {
  type = string
}
variable "private_key_path" {
  type = string
  # NOTE: Em terraform.tfvars use um caminho literal; não tente interpolar path.module.
  # Exemplo de valores válidos:
  #   "secrets/oci_api_key.pem" (relativo ao diretório raiz onde roda terraform)
  #   "C:/Users/alexa/projects/oci-iac/secrets/oci_api_key.pem" (caminho absoluto Windows)
  validation {
    condition     = fileexists(var.private_key_path)
    error_message = "private_key_path deve apontar para um arquivo PEM existente de chave privada OCI. Não use interpolação; forneça um caminho literal."
  }
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
variable "image_id" {
  type    = string
  default = ""
}

# Optional: You can supply values via terraform.tfvars or environment variables (TF_VAR_*)
# Example terraform.tfvars:
# tenancy_ocid = "ocid1.tenancy.oc1..aaaa..."
# user_ocid = "ocid1.user.oc1..aaaa..."
# fingerprint = "aa:bb:cc:dd:..."
# private_key_path = "secrets/oci_api_key.pem"
# region = "us-ashburn-1"
# compartment_ocid = "ocid1.compartment.oc1..aaaa..."
# project_prefix = "demo"
# vcn_cidr = "10.0.0.0/16"
# public_subnet_cidr = "10.0.1.0/24"
# instance_shape = "VM.Standard.E4.Flex"
# instance_ocpus = 1
# instance_memory_gbs = 16
# image_operating_system = "Oracle Linux"
# image_operating_system_version = "8"
# image_id = "" # optional override
