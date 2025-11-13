output "nextcloud_vcn_id" { value = module.nextcloud-network.vcn_id }
output "nextcloud_public_subnet_id" { value = module.nextcloud-network.public_subnet_id }

# output "nextcloud_vm_arm_a1-free_max_instance_id" { value = module.nextcloud-vm-arm-a1-free-max.instance_id }
# output "nextcloud_vm_arm_a1-free_max_instance_public_ip" { value = module.nextcloud-vm-arm-a1-free-max.public_ip }
# output "nextcloud_vm_arm_a1-free_max_instance_private_ip" { value = module.nextcloud-vm-arm-a1-free-max.private_ip }
# output "nextcloud_vm_arm_a1-free_max_instance_image_id" { value = module.nextcloud-vm-arm-a1-free-max.effective_image_id }
# output "nextcloud_vm_arm_a1-free_max_instance_boot_volume_size_gbs" { value = module.nextcloud-vm-arm-a1-free-max.boot_volume_size_gbs }
# output "nextcloud_vm_arm_a1-free_max_instance_data_volume_size_in_gbs" { value = module.nextcloud-vm-arm-a1-free-max.data_volume_id }

output "backend_bucket" {
  value       = var.backend_bucket
  description = "Bucket do backend OCI usado para o state."
}
output "backend_state_key" {
  value       = var.backend_state_key
  description = "Chave (path) do objeto de state no bucket."
}
output "object_storage_namespace" {
  value       = var.object_storage_namespace
  description = "Namespace do Object Storage usado (se fornecido)."
  sensitive   = false
}
