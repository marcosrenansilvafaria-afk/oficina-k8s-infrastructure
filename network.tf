# -----------------------------------------------------------------------------
# Rede dedicada ao EKS, criada DENTRO da VPC do Repositorio 1 (via remote
# state). Subnets, IGW e NAT sao recursos NOVOS, proprios deste state - nao
# modificamos nenhuma subnet/route table que ja pertence ao Repositorio 1,
# evitando conflito de ownership entre os states dos dois repositorios.
# -----------------------------------------------------------------------------

locals {
  vpc_id = data.terraform_remote_state.db.outputs.vpc_id
}

resource "aws_internet_gateway" "this" {
  vpc_id = local.vpc_id

  tags = {
    Name = "oficina-${var.environment}-eks-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "oficina-${var.environment}-eks-public"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "oficina-${var.environment}-eks-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# NAT unico (nao um por AZ) para reduzir custo - aceita como trade-off de
# disponibilidade em um ambiente de estudo/demonstracao. Necessario para os
# worker nodes (em subnets privadas) baixarem imagens de container e
# alcancarem APIs da AWS.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "oficina-${var.environment}-eks-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "oficina-${var.environment}-eks-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_subnet" "eks_private" {
  count = length(var.eks_private_subnet_cidrs)

  vpc_id                  = local.vpc_id
  cidr_block              = var.eks_private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "oficina-${var.environment}-eks-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "eks_private" {
  vpc_id = local.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "oficina-${var.environment}-eks-private-rt"
  }
}

resource "aws_route_table_association" "eks_private" {
  count = length(aws_subnet.eks_private)

  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.eks_private.id
}
