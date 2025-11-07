output "instance_id" { value = oci_core_instance.this.id }
output "public_ip" { value = data.oci_core_vnic.primary.public_ip_address }

