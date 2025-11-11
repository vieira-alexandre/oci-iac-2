resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${var.dns_label_prefix}-vcn"
  dns_label      = var.dns_label_prefix
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.dns_label_prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.dns_label_prefix}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    description       = "Roteamento para Internet"
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.dns_label_prefix}-public-sl"

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "SSH"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Saida irrestrita"
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.dns_label_prefix}-public-subnet"
  dns_label                  = "pub"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

# # Network Security Group dedicado para a instancia de banco (vm-amd-db)
# resource "oci_core_network_security_group" "db" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.this.id
#   display_name   = "${var.dns_label_prefix}-db-nsg"
# }
#
# # Regra de saída irrestrita (para atualizações, etc.)
# resource "oci_core_network_security_group_security_rule" "db_egress_all" {
#   network_security_group_id = oci_core_network_security_group.db.id
#   direction                 = "EGRESS"
#   protocol                  = "all"
#   destination               = "0.0.0.0/0"
#   destination_type          = "CIDR_BLOCK"
#   description               = "Saída irrestrita"
# }
