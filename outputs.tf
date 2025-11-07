output "vcn_id" { value = module.network.vcn_id }
output "public_subnet_id" { value = module.network.public_subnet_id }
# output "instance_id" { value = module.compute.instance_id }
# output "instance_public_ip" { value = module.compute.public_ip }

output "backend_bucket" {
  value       = var.backend_bucket
  description = "Bucket do backend S3/OCI usado para o state."
}
output "backend_state_key" {
  value       = var.backend_state_key
  description = "Chave (path) do objeto de state no bucket."
}
output "backend_s3_endpoint" {
  value       = var.s3_endpoint
  description = "Endpoint S3 compatível usado pelo backend."
}
output "backend_encrypt" {
  value       = var.backend_encrypt
  description = "Flag encrypt do backend."
}
output "backend_s3_access_key" {
  value       = var.s3_access_key
  description = "Access key (exposta apenas para depuração interna)."
  sensitive   = true
}
