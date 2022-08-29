#-----------------------------------------------------------------------
# Provider region
#-----------------------------------------------------------------------
variable "region" {
  description = "AWS Region for Genesis DevOps School"
  type        = string
  default     = "us-east-1"
}

#-----------------------------------------------------------------------
# Project name
#-----------------------------------------------------------------------
variable "project" {
  description = "The project name"
  type        = string
  default     = "Genesis"
}

#-----------------------------------------------------------------------
# The project Environment
#-----------------------------------------------------------------------
variable "env" {
  description = "The Environment for Genesis DevOps School"
  type        = string
  default     = "dev"
}


#-----------------------------------------------------------------------
# Tags
#-----------------------------------------------------------------------
variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map(any)
  default = {
    Owner = ""
  }
}


#-------------------------------
# EKS module variables (terraform-aws-modules/eks/aws)
#-------------------------------
variable "create_eks" {
  type        = bool
  default     = true
  description = "Create EKS cluster"
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of cluster - used by Terratest for e2e test automation"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.21`)"
  type        = string
  default     = "1.21"
}

#-------------------------------
# EKS Cluster Security Groups
#-------------------------------
variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

#-------------------------------
# EKS Cluster VPC Config
#-------------------------------
variable "cluster_endpoint_public_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the EKS public API server endpoint is enabled. Default to EKS resource and it is true"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the EKS private API server endpoint is enabled. Default to EKS resource and it is false"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

#-------------------------------
# EKS Cluster ENCRYPTION
#-------------------------------
variable "cluster_kms_key_arn" {
  type        = string
  default     = null
  description = "A valid EKS Cluster KMS Key ARN to encrypt Kubernetes secrets"
}

variable "cluster_kms_key_deletion_window_in_days" {
  type        = number
  default     = 30
  description = "The waiting period, specified in number of days (7 - 30). After the waiting period ends, AWS KMS deletes the KMS key"
}

variable "cluster_kms_key_additional_admin_arns" {
  type        = list(string)
  description = "A list of additional IAM ARNs that should have FULL access (kms:*) in the KMS key policy."
  default     = []
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

#-------------------------------
# EKS Cluster Kubernetes Network Config
#-------------------------------
variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "ipv6"], var.cluster_ip_family)
    error_message = "Invalid input, options: \"ipv4\", \"ipv6\"."
  }
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}

#-------------------------------
# EKS Cluster CloudWatch Logging
#-------------------------------
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = false
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable"
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

#-------------------------------
# EKS Cluster IAM role
#-------------------------------

variable "iam_role_path" {
  description = "Cluster IAM role path"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = list(string)
  default     = []
}
#-------------------------------

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

variable "custom_oidc_thumbprints" {
  description = "Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = list(string)
  default     = []
}

variable "cluster_identity_providers" {
  description = "Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA"
  type        = any
  default     = {}
}

#-------------------------------
# Node Groups
#-------------------------------
variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Self-managed node groups configuration"
  type        = any
  default     = {}
}

variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}

#-------------------------------
# Worker Additional Variables
#-------------------------------
variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`"
  type        = bool
  default     = true
}
#rules added by
variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

#-------------------------------
# Fargate
#-------------------------------
variable "fargate_profiles" {
  description = "Fargate profile configuration"
  type        = any
  default     = {}
}

#-------------------------------
# aws-auth Config Map
#-------------------------------
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

variable "eks_readiness_timeout" {
  description = "The maximum time (in seconds) to wait for EKS API server endpoint to become healthy"
  type        = number
  default     = "600"
}

#-------------------------------
# Amazon Managed Prometheus
#-------------------------------
variable "enable_amazon_prometheus" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus service"
}

variable "amazon_prometheus_workspace_alias" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Name"
}

#-------------------------------
# Amazon EMR on EKS
#-------------------------------
variable "enable_emr_on_eks" {
  type        = bool
  default     = false
  description = "Enable EMR on EKS"
}

variable "emr_on_eks_teams" {
  description = "EMR on EKS Teams config"
  type        = any
  default     = {}
}

#-------------------------------
# TEAMS (Soft Multi-tenancy)
#-------------------------------
variable "application_teams" {
  description = "Map of maps of Application Teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of platform teams to create"
  type        = any
  default     = {}
}

#-------------------------------
#  EKS Addons versions
#-------------------------------
# eks_vpc_cni
variable "enable_amazon_eks_vpc_cni" {
  description = "Enable AWS eks_vpc_cni"
  type        = bool
  default     = false
}
variable "eks_vpc_cni_addon_version" {
  type        = string
  default     = "v1.11.0-eksbuild.1"
  description = "Addon version for eks_vpc_cni"
}
# eks_aws_ebs_csi_driver
variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable AWS eks_aws_ebs_csi_driver"
  type        = bool
  default     = false
}
variable "eks_aws_ebs_csi_driver_addon_version" {
  type        = string
  default     = "v1.6.1-eksbuild.1"
  description = "Addon version for eks_aws_ebs_csi_driver"
}
# eks_coredns
variable "enable_amazon_eks_coredns" {
  description = "Enable AWS eks_coredns"
  type        = bool
  default     = false
}
variable "eks_coredns_addon_version" {
  type        = string
  default     = "v1.8.4-eksbuild.1"
  description = "Addon version for eks_coredns"
}
# eks_kube_proxy 
variable "enable_amazon_eks_kube_proxy" {
  description = "Enable AWS eks_kube_proxy"
  type        = bool
  default     = false
}
variable "eks_kube_proxy_addon_version" {
  type        = string
  default     = "v1.21.2-eksbuild.2"
  description = "Addon version for eks_kube_proxy"
}
# ingress_nginx
variable "enable_ingress_nginx" {
  description = "Enable AWS ingress_nginx"
  type        = bool
  default     = false
}
variable "ingress_nginx_addon_version" {
  type        = string
  default     = "3.33.0" # TODO find actual versions 
  description = "Addon version for ingress_nginx"
}
# load_balancer_controller
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS load_balancer_controller"
  type        = bool
  default     = false
}
variable "load_balancer_controller_addon_version" {
  type        = string
  default     = "1.3.2"
  description = "Addon version for load_balancer_controller"
}

# metrics_server
variable "enable_metrics_server" {
  description = "Enable AWS metrics_server"
  type        = bool
  default     = false
}
variable "metrics_server_addon_version" {
  type        = string
  default     = "3.8.1"
  description = "Addon version for metrics_server"
}
# cluster_autoscaler
variable "enable_cluster_autoscaler" {
  description = "Enable AWS cluster_autoscaler"
  type        = bool
  default     = false
}
variable "cluster_autoscaler_addon_version" {
  type        = string
  default     = "9.15.0"
  description = "Addon version for cluster_autoscaler"
}
# argocd
variable "enable_argocd" {
  description = "Enable AWS argocd"
  type        = bool
  default     = false
}
variable "argocd_addon_version" {
  type        = string
  default     = "3.33.3"
  description = "Addon version for argocd"
}
# for_fluentbit
variable "enable_aws_for_fluentbit" {
  description = "Enable AWS fluentbit"
  type        = bool
  default     = false
}
variable "aws_for_fluentbit_addon_version" {
  type        = string
  default     = "0.1.11"
  description = "Addon version for fluentbit"
}
# prometheus
variable "enable_prometheus" {
  description = "Enable AWS prometheus"
  type        = bool
  default     = false
}
variable "prometheus_addon_version" {
  type        = string
  default     = "15.3.0"
  description = "Addon version for prometheusr"
}
# cloudwatch_metrics
variable "enable_aws_cloudwatch_metrics" {
  description = "Enable AWS prometheus"
  type        = bool
  default     = false
}
variable "cloudwatch_metrics_addon_version" {
  type        = string
  default     = ""
  description = "Addon version for prometheusr"
}

variable "enable_kubernetes_dashboard" {
  description = "Enable AWS prometheus"
  type        = bool
  default     = false
}

variable "enable_kube_prometheus_stack" {
  description = "Enable kube-prometheus-stack"
  type        = bool
  default     = false
}

variable "enable_grafana" {
  description = "Enable grafana"
  type        = bool
  default     = false
}

variable "grafana_pass" {
  description = "Password for grafana"
  type        = any
  default     = "p@s$w0rd"
}

variable "kube_prometheus_stack_grafana_pass" {
  description = "Password for grafana in kube_prometheus_stack"
  type        = any
  default     = "p@s$w0rd"
}

#-------------------------------
#  Deploy APP
#-------------------------------
variable "deploy_app" {
  description = "Deploy app by provisioner local-exec"
  type        = bool
  default     = false
}

variable "MYSQL_PASSWORD" {
  description = "MYSQL PASSWORD env for APP"
  type        = any
  default     = ""
  sensitive   = true
}

variable "MYSQL_ROOT_PASSWORD" {
  description = "MYSQL ROOT PASSWORD env for APP"
  type        = any
  default     = ""
  sensitive   = true
}
