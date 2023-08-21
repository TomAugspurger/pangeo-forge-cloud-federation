provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args    = ["get-token", "--environment", "AzurePublicCloud", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
      command = "kubelogin"
    }
 }
}



resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "support"
  create_namespace = true
  version          = var.prometheus_version

  set {
    # We don't use alertmanager
    name  = "alertmanager.enabled"
    value = false
  }

  set {
    # We don't use pushgateway either
    name  = "pushgateway.enabled"
    value = false
  }

  set {
    name  = "server.persistentVolume.size"
    value = var.prometheus_disk_size
  }

  set {
    name  = "server.retention"
    value = "${var.prometheus_metrics_retention_days}d"
  }

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.prometheus_hostname
  }

  set {
    # Double \\ is neded so the entire last part of the name is used as key
    name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
  }

  set {
    # We have a persistent disk attached, so the default (RollingUpdate)
    # can sometimes get 'stuck' and require pods to be manually deleted.
    name  = "strategy.type"
    value = "Recreate"
  }
  # wait = true
  depends_on = [
    azurerm_kubernetes_cluster.cluster
  ]
}

resource "helm_release" "ingress" {
  name             = "ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "support"
  create_namespace = true
  version          = var.nginx_ingress_version

  wait = true
  depends_on = [
    azurerm_kubernetes_cluster.cluster
  ]
}
