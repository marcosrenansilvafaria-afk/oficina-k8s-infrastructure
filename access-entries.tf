# Concede acesso de deploy (kubectl) ao cluster para a IAM Role do GitHub
# Actions do Repositorio 4 (oficina-app). Sem isso, a role teria permissao
# IAM para chamar a API do EKS (DescribeCluster etc), mas nao teria RBAC
# dentro do cluster - acesso ao Kubernetes e concedido separadamente via
# EKS Access Entries, nao via IAM sozinho.
resource "aws_eks_access_entry" "app_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.app_deploy_role_arn
}

resource "aws_eks_access_policy_association" "app_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.app_deploy_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["oficina"]
  }
}
