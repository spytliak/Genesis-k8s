#---------------------------------------------------------------
# Providers
#---------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.10.0"

  # EKS CLUSTER
  create_eks      = var.create_eks
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS Cluster IAM role
  enable_irsa = var.enable_irsa

  # EKS Cluster endpoints
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # EKS MANAGED NODE GROUPS
  managed_node_groups = { 
    mg =  merge(
      var.managed_node_groups, {
        subnet_ids      = module.vpc.private_subnets
      }
    )
  }

  tags = local.tags

}

resource "time_sleep" "wait_20_seconds_after_eks_blueprints" {
  depends_on = [
    module.eks_blueprints.managed_node_groups
  ]
  create_duration = "20s"
}

#---------------------------------------------------------------
# EKS Blueprints kubernetes addons 
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.10.0"

  eks_cluster_id               = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint         = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider            = module.eks_blueprints.oidc_provider
  eks_cluster_version          = module.eks_blueprints.eks_cluster_version
  eks_worker_security_group_id = module.eks_blueprints.worker_node_security_group_id
  auto_scaling_group_names     = module.eks_blueprints.self_managed_node_group_autoscaling_groups

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni = var.enable_amazon_eks_vpc_cni
  amazon_eks_vpc_cni_config = {
    addon_name        = "vpc-cni"
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    service_account   = "aws-node"
    resolve_conflicts = "OVERWRITE"
    namespace         = "kube-system"
    timeout           = "600"
    description = "vpc-cni helm Chart deployment configuration"
  }

  enable_amazon_eks_aws_ebs_csi_driver = var.enable_amazon_eks_aws_ebs_csi_driver
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_name        = "aws-ebs-csi-driver"
    addon_version     = data.aws_eks_addon_version.default["aws-ebs-csi-driver"].version
    service_account   = "ebs-csi-controller-sa"
    resolve_conflicts = "OVERWRITE"
    namespace         = "kube-system"
    timeout           = "600"
    description = "aws-ebs-csi-driver helm Chart deployment configuration"
  }

  enable_amazon_eks_coredns = var.enable_amazon_eks_coredns
  amazon_eks_coredns_config = {
    addon_name        = "coredns"
    addon_version     = data.aws_eks_addon_version.default["coredns"].version
    service_account   = "coredns"
    resolve_conflicts = "OVERWRITE"
    namespace         = "kube-system"
    timeout           = "600"
    description = "coredns helm Chart deployment configuration"
  }

  enable_amazon_eks_kube_proxy = var.enable_amazon_eks_kube_proxy
  amazon_eks_kube_proxy_config = {
    addon_name        = "kube-proxy"
    addon_version     = data.aws_eks_addon_version.default["kube-proxy"].version
    service_account   = "kube-proxy"
    resolve_conflicts = "OVERWRITE"
    namespace         = "kube-system"
    timeout           = "600"
    description = "kube-proxy helm Chart deployment configuration"
  }

  # Ingress
  enable_ingress_nginx = var.enable_ingress_nginx
  ingress_nginx_helm_config = {
    name             = "ingress-nginx"
    chart            = "ingress-nginx"
    repository       = "https://kubernetes.github.io/ingress-nginx"
    namespace        = "ingress-nginx"
    create_namespace = true
    timeout          = "600"
    description = "ingress-nginx helm Chart deployment configuration"
    values           = [templatefile("../../helm/ingress-nginx/chart/values.yaml", {})]
  }

  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller_helm_config = {
    name       = "aws-load-balancer-controller"
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    namespace  = "kube-system"
    timeout    = "600"
    description = "aws-load-balancer-controller helm Chart deployment configuration"
    # values = [templatefile("../../helm/aws_load_balancer_controller/chart/values.yaml", {})]
  }

  # Add-ons
  enable_metrics_server = var.enable_metrics_server
  metrics_server_helm_config = {
    name        = "metrics-server"
    chart       = "metrics-server"
    repository  = "https://kubernetes-sigs.github.io/metrics-server/"
    namespace   = "kube-system"
    timeout     = "600"
    description = "Metric server helm Chart deployment configuration"
    # values = [templatefile("../../helm/metrics_server/chart/values.yaml", {})]
  }

  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  cluster_autoscaler_helm_config = {
    name        = "cluster-autoscaler"
    chart       = "cluster-autoscaler"
    repository  = "https://kubernetes.github.io/autoscaler"
    namespace   = "kube-system"
    timeout     = "600"
    description = "Cluster AutoScaler helm Chart deployment configuration."
    # values = [templatefile("../../helm/cluster_autoscaler/chart/values.yaml", {})]
  }

  enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics
  aws_cloudwatch_metrics_helm_config = {
    name        = "aws-cloudwatch-metrics"
    chart       = "aws-cloudwatch-metrics"
    repository  = "https://aws.github.io/eks-charts"
    namespace   = "amazon-cloudwatch"
    timeout     = "600"
    description = "aws-cloudwatch-metrics Helm Chart deployment configuration"
    # values = [templatefile("../../helm/cloudwatch_metrics/chart/values.yaml", {})]
  }

  enable_argocd = var.enable_argocd
  argocd_helm_config = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    namespace        = "argocd"
    timeout          = "600"
    create_namespace = true
    description      = "The ArgoCD Helm Chart deployment configuration"
    # values = [templatefile("../../helm/argocd/chart/values.yaml", {})]
  }

  enable_aws_for_fluentbit = var.enable_aws_for_fluentbit
  aws_for_fluentbit_helm_config = {
    name        = "aws-for-fluent-bit"
    chart       = "aws-for-fluent-bit"
    repository  = "https://aws.github.io/eks-charts"
    namespace   = "aws-for-fluent-bit"
    timeout     = "600"
    description = "aws-for-fluent-bit Helm Chart deployment configuration"
    # values = [templatefile("../../helm/fluentbit/chart/values.yaml", {})]
  }

  enable_prometheus = var.enable_prometheus
  prometheus_helm_config = {
    name        = "prometheus"
    chart       = "prometheus"
    repository  = "https://prometheus-community.github.io/helm-charts"
    namespace   = "prometheus"
    timeout     = "600"
    description = "Prometheus helm Chart deployment configuration"
    # values = [templatefile("../../helm/prometheus/chart/values.yaml", {})]
  }

  enable_kube_prometheus_stack = var.enable_kube_prometheus_stack
  kube_prometheus_stack_helm_config = {
    name       = "kube-prometheus-stack"
    chart      = "kube-prometheus-stack"
    repository = "https://prometheus-community.github.io/helm-charts"
    namespace  = "kube-prometheus-stack"
    timeout    = "600"
    description = "kube-prometheus-stack helm Chart deployment configuration"
    # values      = [templatefile("../../helm/kube-prometheus-stack/chart/values.yaml", {})]
    set = [
      {
        name  = "kubeProxy.enabled"
        value = false
      }
    ],
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = var.kube_prometheus_stack_grafana_pass
      }
    ]
  }

  enable_grafana = var.enable_grafana
  grafana_helm_config = {
    name       = "grafana"
    chart      = "grafana"
    repository = "https://grafana.github.io/helm-charts"
    namespace  = "grafana"
    description = "Grafana Helm Chart deployment configuration"
    # values      = [templatefile("../../helm/grafana/chart/values.yaml", {})]
    set_sensitive = [
      {
        name  = "adminPassword"
        value = "var.grafanapass"
      }
    ]
  }

  enable_kubernetes_dashboard = var.enable_kubernetes_dashboard
  kubernetes_dashboard_helm_config = {
    name        = "kubernetes-dashboard"
    repository  = "https://kubernetes.github.io/dashboard/"
    chart       = "kubernetes-dashboard"
    namespace   = "kube-system"
    timeout     = "600"
    description = "Kubernetes Dashboard Helm Chart"
    # values = [templatefile("../../helm/kubernetes_dashboard/chart/values.yaml", {})]
  }

  enable_kubecost = var.enable_kubecost
  kubecost_helm_config = {
    name       = "kubecost"
    repository = "oci://public.ecr.aws/kubecost"
    chart      = "cost-analyzer"
    namespace  = "kubecost"
    description = "Kubecost Helm Chart deployment configuration"
    # values = [templatefile("../../helm/kubecost/chart/values.yaml", {})]
  }

  tags = local.tags

  depends_on = [
    time_sleep.wait_20_seconds_after_eks_blueprints
  ]
}

#---------------------------------------------------------------
# Supporting Resources (VPC)
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
    "subnet/alb"                                  = "True"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "subnet/alb"                                  = "True"
  }

  tags = local.tags
}