resource "kubectl_manifest" "ai_ml_observability_yaml" {
  count     = var.enable_ai_ml_observability_stack ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/ai-ml-observability.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "aibrix_dependency_yaml" {
  count     = var.enable_aibrix_stack ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/aibrix-dependency.yaml", { aibrix_version = var.aibrix_stack_version })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "aibrix_core_yaml" {
  count     = var.enable_aibrix_stack ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/aibrix-core.yaml", { aibrix_version = var.aibrix_stack_version })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "nvidia_nim_yaml" {
  count     = var.enable_nvidia_nim_stack ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/nvidia-nim-operator.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# NVIDIA K8s DRA Driver
resource "kubectl_manifest" "nvidia_dra_driver" {
  count     = var.enable_nvidia_dra_driver && var.enable_nvidia_gpu_operator ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/nvidia-dra-driver.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# GPU Operator
resource "kubectl_manifest" "nvidia_gpu_operator" {
  count = var.enable_nvidia_gpu_operator ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/nvidia-gpu-operator.yaml", {
    service_monitor_enabled = var.enable_ai_ml_observability_stack
  })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# NVIDIA Device Plugin (standalone - GPU scheduling only)
resource "kubectl_manifest" "nvidia_device_plugin" {
  count     = !var.enable_nvidia_gpu_operator && var.enable_nvidia_device_plugin ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/nvidia-device-plugin.yaml", {})

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# DCGM Exporter (standalone - GPU monitoring only)
resource "kubectl_manifest" "nvidia_dcgm_exporter" {
  count = !var.enable_nvidia_gpu_operator && var.enable_nvidia_dcgm_exporter ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/nvidia-dcgm-exporter.yaml", {
    service_monitor_enabled = var.enable_ai_ml_observability_stack
  })

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# Cert Manager
resource "kubectl_manifest" "cert_manager_yaml" {
  count     = var.enable_cert_manager || var.enable_slurm_operator ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/cert-manager.yaml")

  depends_on = [
    module.eks_blueprints_addons
  ]
}

# Slinky Slurm Operator
resource "kubectl_manifest" "slurm_operator_yaml" {
  count     = var.enable_slurm_operator ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/slurm-operator.yaml")

  depends_on = [
    module.eks_blueprints_addons,
    kubectl_manifest.cert_manager_yaml
  ]
}

# MPI Operator
resource "kubectl_manifest" "mpi_operator" {
  count     = var.enable_mpi_operator ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/mpi-operator.yaml")

  depends_on = [
    module.eks_blueprints_addons,
    kubectl_manifest.cert_manager_yaml
  ]
}

# Langfuse
resource "kubectl_manifest" "langfuse_yaml" {
  count = var.enable_langfuse ? 1 : 0
  yaml_body = file("${path.module}/argocd-addons/observability/langfuse/langfuse.yaml")

  depends_on = [
    module.eks_blueprints_addons,
  ]
}

# Langfuse Secret
# TODO: Move this

resource "random_bytes" "langfuse_secret" {
  count  = var.enable_langfuse ? 8 : 0
  length = 32
}

resource "kubectl_manifest" "langfuse_secret_yaml" {
  count = var.enable_langfuse ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/observability/langfuse/langfuse-secret.yaml", {
    salt                = random_bytes.langfuse_secret[0].hex
    encryption-key      = random_bytes.langfuse_secret[1].hex
    nextauth-secret     = random_bytes.langfuse_secret[2].hex
    postgresql-password = random_bytes.langfuse_secret[3].hex
    clickhouse-password = random_bytes.langfuse_secret[4].hex
    redis-password      = random_bytes.langfuse_secret[5].hex
    s3-user             = random_bytes.langfuse_secret[6].hex
    s3-password         = random_bytes.langfuse_secret[7].hex
  })

  depends_on = [
    kubectl_manifest.langfuse_yaml
  ]
}

# Gitlab
resource "kubectl_manifest" "gitlab_yaml" {
  count = var.enable_gitlab ? 1 : 0
  yaml_body = templatefile("${path.module}/argocd-addons/devops/gitlab/gitlab.yaml", {
    proxy-real-ip-cidr  = local.vpc_cidr
    acm_certificate_arn = data.aws_acm_certificate.issued[0].arn
    domain              = var.acm_certificate_domain
  })

  depends_on = [
    module.eks_blueprints_addons,
  ]
}
