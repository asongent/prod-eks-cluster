
resource "aws_eks_addon" "ebs-csi-driver" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
}


resource "aws_eks_addon" "eks-pod-identity" {
  cluster_name = var.cluster_name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"
}


resource "aws_eks_addon" "kube-proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
}