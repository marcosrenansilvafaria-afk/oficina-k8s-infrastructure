# -----------------------------------------------------------------------------
# Geral
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados. Deve ser a mesma do Repositório 1 (RDS)."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente (ex: production, development). Deve corresponder ao ambiente do Repositório 1 cujo state sera lido."
  type        = string
  default     = "development"
}

variable "db_state_bucket" {
  description = "Nome do bucket S3 onde o state do Repositório 1 (oficina-db-infrastructure) está armazenado."
  type        = string
}

# -----------------------------------------------------------------------------
# Rede (subnets novas, dedicadas ao EKS, dentro da VPC do Repositorio 1)
# -----------------------------------------------------------------------------

variable "public_subnet_cidr" {
  description = "CIDR da subnet publica (usada apenas pelo NAT Gateway) dentro da VPC do Repositorio 1."
  type        = string
  default     = "10.0.10.0/24"
}

variable "eks_private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (2 AZs) onde os worker nodes do EKS serao provisionados."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones usadas pelas subnets do EKS. Deve ter o mesmo tamanho de eks_private_subnet_cidrs (a subnet publica usa a primeira AZ da lista)."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# -----------------------------------------------------------------------------
# EKS
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
  default     = "oficina-eks"
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes no cluster EKS."
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "Tipo de instância EC2 dos worker nodes."
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Número desejado de worker nodes."
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Número mínimo de worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Número máximo de worker nodes."
  type        = number
  default     = 2
}
