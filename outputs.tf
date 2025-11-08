output "vcn_id" { value = module.network-1.vcn_id }
output "public_subnet_id" { value = module.network-1.public_subnet_id }

output "instance_id" { value = module.vm-amd.instance_id }
output "instance_public_ip" { value = module.vm-amd.public_ip }
output "instance_image_id" { value = module.vm-amd.effective_image_id }
output "instance_boot_volume_size_gbs" { value = module.vm-amd.boot_volume_size_gbs }

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
