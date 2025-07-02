####
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

### EBS CSI config
resource "aws_iam_role" "ebs-csi-driver" {
  name               =  "${var.cluster_name}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role_policy_attachment" "ebs-csi-driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs-csi-driver.name
}

resource "aws_eks_pod_identity_association" "ebs-csi-driver" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs-csi-driver.arn
}

### S3 ReadOnly Access
resource "aws_iam_role" "s3-readonly-access" {
  name               =  "${var.cluster_name}-s3-readonly-access-role" 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "s3-readonly-access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.s3-readonly-access.name
}

resource "aws_eks_pod_identity_association" "s3-readonly-access" {
  cluster_name    = var.cluster_name
  namespace       = "airflow"
  service_account = "airflow-worker"
  role_arn        = aws_iam_role.s3-readonly-access.arn
}

### CREATE KMS key for Secret encryption

#  resource "aws_kms_key" "argocd-kms-key" {
#   description             = "KMS key for encrypting and decryption of secrets with argocd"
#   enable_key_rotation     = true
#   is_enabled              = true
#  }

## ArgoCD po identity config with kms
resource "aws_iam_role" "argocd-enc-depc-key" {
  name               =  "${var.cluster_name}-argocd-enc-key-role" 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

## CUSTOM IAM POLICY
resource "aws_iam_policy" "kms-key-policy" {
  name        = "${var.cluster_name}-kms-key-policy"
  description = "This policy inherits permissions to allow argocd encrypt and decrypt secrets"
  # policy      = data.aws_iam_policy_document.assume_role.json
  policy      = <<EOT
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "argocdencdecriptkey",
      "Action": [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:Sign",
        "kms:Verify"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOT  
}
resource "aws_iam_role_policy_attachment" "argocd-enc-depc-key" {
  policy_arn = aws_iam_policy.kms-key-policy.arn
  role       = aws_iam_role.argocd-enc-depc-key.name
}

resource "aws_eks_pod_identity_association" "kms-key" {
  cluster_name    = var.cluster_name
  namespace       = "argocd"
  service_account = "argocd-repo-server"
  role_arn        = aws_iam_role.argocd-enc-depc-key.arn
}



###AWS ELB Controller
resource "aws_iam_role" "aws-load-balancer-controller-role" {
  name               =  "${var.cluster_name}-eks-loadBalancerControllerRole" 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_policy" "aws-load-balancer-controller-policy"  {
    name        = "${var.cluster_name}-loadBalancerControllerIAMPolicy" 
    description = "Enables the cluster to create custom LB"
    policy      = file("policies/load-balancer-controller-iam_policy.json")
 }

resource "aws_iam_role_policy_attachment" "aws-load-balancer-controller" {
  policy_arn = aws_iam_policy.aws-load-balancer-controller-policy.arn
  role       = aws_iam_role.aws-load-balancer-controller-role.name
}


resource "aws_eks_pod_identity_association" "aws-load-balancer-controller" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws-load-balancer-controller-role.arn
}


### External Secret Operator
resource "aws_iam_role" "aws-role-for-eso" {
  name               =  "aws-role-for-eso" 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "aws-role-for-eso-policy"  {
    name        = "${var.cluster_name}-secretManagerIAMPolicy" 
    description = "Enables sso to read from AWS secret manager"
    policy      = file("policies/secret-manager-policy.json")
 }

resource "aws_eks_pod_identity_association" "aws-role-for-eso-asso" {
  cluster_name    = var.cluster_name
  namespace       = "eso-operator"
  service_account = "external-secrets-cert-controller"
  role_arn        = aws_iam_role.aws-role-for-eso.arn
}

### Karpenter role
resource "aws_iam_role" "karpenter-role" {
  name = "${var.cluster_name}-karpenter-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "pods.eks.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "karpenter_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter-role.name
}

resource "aws_iam_role_policy_attachment" "karpenter_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter-role.name
}

resource "aws_iam_role_policy_attachment" "karpenter_AmazonEC2ContainerRegistryPullOnly"{
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.karpenter-role.name
}
resource "aws_iam_role_policy_attachment" "karpenter_AmazonSSMManagedInstanceCore"{
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter-role.name
}

resource "aws_eks_pod_identity_association" "karpenter-role-pda" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter-role.arn
}