# Libera a porta 5432 no Security Group do RDS (criado no Repositorio 1) a
# partir do Security Group compartilhado dos worker nodes do EKS, para que a
# aplicacao NestJS (Repositorio 4, rodando nos pods) consiga acessar o banco.
# Referencia por ID de Security Group (nao CIDR), mesmo padrao ja usado no
# Repositorio 2 (Lambda de autenticacao).
resource "aws_security_group_rule" "rds_ingress_from_eks_nodes" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.db.outputs.rds_security_group_id
  source_security_group_id = module.eks.node_security_group_id
  description              = "Acesso PostgreSQL a partir dos worker nodes do EKS (Repositorio 3)"
}
