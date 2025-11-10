output "instance_id" { value = oci_core_instance.this.id }
output "public_ip" { value = data.oci_core_vnic.primary.public_ip_address }
output "effective_image_id" { value = oci_core_instance.this.source_details[0].source_id }
output "boot_volume_size_gbs" { value = var.boot_volume_size_gbs }
output "private_ip" { value = data.oci_core_vnic.primary.private_ip_address }
