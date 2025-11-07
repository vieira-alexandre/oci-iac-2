variable "compartment_ocid" {
  description = "The OCID of the compartment where the resources will be created"
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block for the Virtual Cloud Network (VCN)"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "dns_label_prefix" {
  description = "The prefix for the DNS label"
  type        = string
}
