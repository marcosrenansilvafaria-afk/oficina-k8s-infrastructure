# Modulo oficial terraform-aws-modules/eks/aws: cobre cluster, OIDC/IRSA,
# managed node groups e addons gerenciados com poucas linhas, seguindo o
# padrao de mercado em vez de recursos nativos escritos a mao.
#checkov:skip=CKV_TF_1: Modulo vem do Terraform Registry (nao de um repositorio git), onde o pin correto e por constraint de versao (version = "~> 20.0"), nao por commit hash - a checagem se aplica a modulos com source do tipo git::.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.cluster_name}-${var.environment}"
  cluster_version = var.kubernetes_version

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.eks_private[*].id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Sem logging do control plane no CloudWatch Logs por padrao - evita custo
  # de ingestao/armazenamento nao coberto pelo free tier neste projeto de
  # estudo/demonstracao.
  cluster_enabled_log_types = []

  # Sem KMS CMK para encriptar secrets do cluster - a chave gerenciada pela
  # AWS ja protege o etcd por padrao; uma CMK propria teria custo mensal
  # adicional (~US$1/mes).
  cluster_encryption_config = {}

  enable_irsa = true

  eks_managed_node_group_defaults = {
    instance_types = [var.node_instance_type]
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      subnet_ids = aws_subnet.eks_private[*].id
    }
  }

  # Addons gerenciados pelo EKS - gratuitos, apenas software (nao geram custo
  # adicional alem da propria instancia do node onde rodam).
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  tags = {
    Name = "${var.cluster_name}-${var.environment}"
  }

  depends_on = [aws_nat_gateway.this]
}
