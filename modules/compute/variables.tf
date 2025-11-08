variable "compartment_ocid" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "instance_shape" {
  type = string
}

variable "ocpus" {
  type = number
}

variable "memory_in_gbs" {
  type = number
}

variable "instance_display_name" {
  type = string
}

variable "image_operating_system" {
  type = string
}

variable "image_operating_system_version" {
  type = string
}

variable "image_id" {
  type    = string
  default = ""
}

# Opcional: se null usa tamanho default da imagem. Defina >=50 para sobrepor.
variable "boot_volume_size_gbs" {
  type        = number
  description = "Tamanho do boot volume em GB (>=50). Null para usar default da imagem."
  default     = null
}
