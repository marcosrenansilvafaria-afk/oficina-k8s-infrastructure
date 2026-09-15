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

  depends_on = [module.eks]
}
