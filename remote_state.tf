# Le o state do Repositorio 1 (oficina-db-infrastructure) para reaproveitar a
# VPC e o Security Group do RDS, sem duplicar configuracao manualmente.
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_state_bucket
    key    = "oficina-db/terraform.tfstate"
    region = var.aws_region
  }
}
