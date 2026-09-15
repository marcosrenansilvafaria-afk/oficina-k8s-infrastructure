# Backend remoto (S3 + DynamoDB lock) - reaproveita o MESMO bucket e tabela de
# lock dos Repositorios 1 e 2, com uma "key" propria para isolar o state
# deste repositorio.
terraform {
  backend "s3" {
    key            = "oficina-k8s/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "oficina-db-terraform-locks"
  }
}
