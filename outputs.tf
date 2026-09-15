output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster EKS."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificado CA do cluster (base64), usado por kubectl/CI para autenticar."
  value       = module.eks.cluster_certificate_authority_data
}

output "node_security_group_id" {
  description = "ID do Security Group compartilhado pelos worker nodes do EKS (referenciado pela regra de ingress no RDS)."
  value       = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster (IRSA), para uso por outros repositorios que precisem associar IAM Roles a Service Accounts."
  value       = module.eks.oidc_provider_arn
}

output "update_kubeconfig_command" {
  description = "Comando para configurar o kubectl local apontando para este cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
