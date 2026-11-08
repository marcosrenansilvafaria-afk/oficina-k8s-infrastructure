# IRSA (IAM Roles for Service Accounts) para o oficina-os-service publicar/
# consumir eventos do Saga via SNS/SQS em runtime. Descoberto como gap real
# ao validar o deploy ponta a ponta (Sprint 6, "hora do video"): sem isso,
# o pod usa a IAM role do node do EKS (que nao tem permissao SNS/SQS) em vez
# de uma identidade propria - o publish do SagaPublisher falhava com
# "not authorized to perform: SNS:Publish". O design original (ver README do
# oficina-messaging-infra, secao "Seguranca") previa que cada microsservico
# teria sua propria role de runtime com attach na policy correspondente
# (oficina-saga-<servico>-policy); como o oficina-os-service nao tem
# Terraform proprio (so k8s/*.yaml aplicados via kubectl na CI), essa role
# e criada aqui, onde o OIDC provider do cluster (IRSA) ja existe.
data "aws_iam_policy_document" "os_service_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:oficina:oficina-os-service"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "os_service_runtime" {
  name               = "oficina-os-service-runtime"
  assume_role_policy = data.aws_iam_policy_document.os_service_irsa_trust.json
}

# Policy ja criada pelo oficina-messaging-infra (sns:Publish no topico FIFO +
# sqs:ReceiveMessage/DeleteMessage/GetQueueAttributes na propria fila/DLQ).
resource "aws_iam_role_policy_attachment" "os_service_saga" {
  role       = aws_iam_role.os_service_runtime.name
  policy_arn = "arn:aws:iam::699372251061:policy/oficina-saga-os-service-policy"
}
