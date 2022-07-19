#-----------------------------------------------------------------------
# Provider region
#-----------------------------------------------------------------------
region = "us-east-1"

#-------------------------------
# EKS Cluster VPC Config
#-------------------------------
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true

#-------------------------------
# EKS module variables (terraform-aws-modules/eks/aws)
#-------------------------------
cluster_version = "1.22"
cluster_name    = "blueprint-eks"
create_eks      = true

#-------------------------------
# aws-auth Config Map
#-------------------------------
eks_readiness_timeout = 600

#-------------------------------
#  EKS Addons versions
#-------------------------------
# eks_vpc_cni
enable_amazon_eks_vpc_cni = true

# eks_aws_ebs_csi_driver
enable_amazon_eks_aws_ebs_csi_driver = true

# eks_coredns
enable_amazon_eks_coredns = true

# eks_kube_proxy
enable_amazon_eks_kube_proxy = true

# ingress_nginx
enable_ingress_nginx = true

# load_balancer_controller
enable_aws_load_balancer_controller = true

# metrics_server
enable_metrics_server = true

# cluster_autoscaler
enable_cluster_autoscaler = true

# argocd
enable_argocd = true

# prometheus
enable_prometheus = false

# cloudwatch_metrics
enable_aws_cloudwatch_metrics = true

# kubernetes_dashboard
enable_kubernetes_dashboard = true

#-------------------------------
# EKS Cluster IAM role
#-------------------------------
# IRSA is required for the addons provided
enable_irsa = true

#-------------------------------
# EKS Cluster CloudWatch Logging
#-------------------------------
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


#-----------------------------------------------------------------------
# Tags
#-----------------------------------------------------------------------
common_tags = {
  Owner   = "Serhii Pytliak"
  Project = "Genesis DevOps School"
  Email   = "serhii.pytliak@gmail.com"
}
