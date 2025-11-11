output "instance_id" { value = oci_core_instance.this.id }
output "public_ip" { value = data.oci_core_vnic.primary.public_ip_address }
output "effective_image_id" { value = oci_core_instance.this.source_details[0].source_id }
output "boot_volume_size_gbs" { value = var.boot_volume_size_gbs }
output "private_ip" { value = data.oci_core_vnic.primary.private_ip_address }

output "data_volume_id" { value = length(oci_core_volume.data) == 1 ? oci_core_volume.data[0].id : null }
output "data_volume_size_in_gbs" { value = length(oci_core_volume.data) == 1 ? oci_core_volume.data[0].size_in_gbs : null }
output "data_volume_attachment_id" { value = length(oci_core_volume_attachment.data_attach) == 1 ? oci_core_volume_attachment.data_attach[0].id : null }
output "data_volume_backup_policy_assignment_id" { value = length(oci_core_volume_backup_policy_assignment.data_policy) == 1 ? oci_core_volume_backup_policy_assignment.data_policy[0].id : null }
