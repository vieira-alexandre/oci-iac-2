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

# Default 50GB para atender mínimo de imagens atuais; pode ser sobreposto.
variable "boot_volume_size_gbs" {
  type        = number
  description = "Tamanho do boot volume em GB (>=50). Use null para deixar provider decidir (não recomendado se imagem exigir >=50)."
  default     = 50
}

# Chaves SSH autorizadas (uma ou mais linhas). Obrigatória para acesso inicial via SSH.
# Use a chave pública (ex: conteúdo de id_rsa.pub ou id_ed25519.pub). Para múltiplas chaves, separe por \n.
variable "ssh_authorized_keys" {
  type        = string
  description = "Conteúdo da(s) chave(s) pública(s) SSH para acesso inicial (linha(s) authorized_keys)."
  default     = ""
}

variable "network_security_group_ids" {
  type        = list(string)
  description = "Lista de NSG IDs a associar à VNIC primaria da instância."
  default     = []
}

variable "data_volume_size_gbs" {
  type        = number
  description = "Tamanho do volume de dados adicional em GB. Use null ou 0 para não criar."
  default     = null
  validation {
    condition     = var.data_volume_size_gbs == null || var.data_volume_size_gbs == 0 || var.data_volume_size_gbs >= 50
    error_message = "data_volume_size_gbs deve ser null, 0 ou >= 50."
  }
}

variable "data_volume_display_name" {
  type        = string
  description = "Display name do volume de dados. Default: <instance_display_name>-data se não fornecido."
  default     = null
}

variable "data_volume_attachment_type" {
  type        = string
  description = "Tipo de attachment do volume de dados: paravirtualized ou iscsi."
  default     = "paravirtualized"
  validation {
    condition     = contains(["paravirtualized", "iscsi"], var.data_volume_attachment_type)
    error_message = "data_volume_attachment_type deve ser paravirtualized ou iscsi."
  }
}

variable "data_volume_backup_policy_id" {
  type        = string
  description = "Opcional: ID de uma Backup Policy para associar ao volume de dados."
  default     = null
}
