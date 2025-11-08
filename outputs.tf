output "vcn_id" { value = module.network.vcn_id }
output "public_subnet_id" { value = module.network.public_subnet_id }
output "instance_id" { value = module.compute.instance_id }
output "instance_public_ip" { value = module.compute.public_ip }
output "instance_image_id" { value = module.compute.effective_image_id }

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
