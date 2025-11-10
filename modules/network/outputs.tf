output "vcn_id" { value = oci_core_vcn.this.id }
output "public_subnet_id" { value = oci_core_subnet.public.id }
output "db_nsg_id" { value = oci_core_network_security_group.db.id }