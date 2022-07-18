#-------------------------------------------------------------------
# DATA
#-------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

# Addon version data source ("vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver" )
data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni"])

  addon_name         = each.value
  kubernetes_version = module.eks_blueprints.eks_cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "default" {
  for_each = toset(["kube-proxy", "coredns", "aws-ebs-csi-driver"])

  addon_name         = each.value
  kubernetes_version = module.eks_blueprints.eks_cluster_version
  most_recent        = false
}
