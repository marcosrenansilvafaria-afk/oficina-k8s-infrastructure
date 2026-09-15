# EKS Access Entries recem-criados levam alguns segundos para propagar antes
# de serem reconhecidos pelo API server do Kubernetes. Sem essa espera, o
# helm_release abaixo pode falhar com "the server has asked for the client
# to provide credentials" mesmo com o Access Entry ja criado no apply atual.
resource "time_sleep" "wait_for_access_entry_propagation" {
  create_duration = "20s"

  depends_on = [
    aws_eks_access_entry.ci_admin,
    aws_eks_access_policy_association.ci_admin,
  ]
}

# Metrics Server nao e um addon gerenciado pelo EKS (diferente de
# coredns/kube-proxy/vpc-cni) - e um chart Helm da comunidade, necessario
# para o HorizontalPodAutoscaler (HPA) da aplicacao (Repositorio 4) funcionar,
# ja que o HPA le metricas de CPU/memoria via metrics.k8s.io, fornecido pelo
# Metrics Server.
resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = false

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  # Depende explicitamente do Access Entry da propria CI (ci_admin) - sem
  # RBAC no cluster, a chamada do provider helm falha com "the server has
  # asked for the client to provide credentials" mesmo com credenciais AWS
  # validas (autenticacao != autorizacao no Kubernetes).
  depends_on = [
    module.eks,
    time_sleep.wait_for_access_entry_propagation,
  ]
}
