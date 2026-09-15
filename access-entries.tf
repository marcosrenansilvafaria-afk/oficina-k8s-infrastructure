# Concede acesso de admin do cluster para a propria IAM Role do GitHub
# Actions deste repositorio (oficina-k8s-infrastructure). O flag
# enable_cluster_creator_admin_permissions (em eks.tf) so concede acesso a
# quem efetivamente criou o cluster (quem rodou o primeiro apply) - se o
# apply rodar novamente via CI, a role da CI precisa do seu proprio Access
# Entry, senao comandos que falam com a API do Kubernetes (ex: helm_release
# do Metrics Server) falham com "the server has asked for the client to
# provide credentials" mesmo com credenciais AWS validas.
resource "aws_eks_access_entry" "ci_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::699372251061:role/oficina-k8s-github-actions"
}

resource "aws_eks_access_policy_association" "ci_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::699372251061:role/oficina-k8s-github-actions"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

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
