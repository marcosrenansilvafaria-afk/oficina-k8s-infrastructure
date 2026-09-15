provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "oficina"
      Component   = "k8s-infrastructure"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Autentica os providers helm/kubernetes no cluster EKS recem-criado usando um
# token de curta duracao (via `aws eks get-token`), sem armazenar credenciais
# de longa duracao no state.
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
