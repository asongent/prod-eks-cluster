resource "aws_iam_role" "worker_node_role" {
  name = "${var.cluster_name}-cpu-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_instance_profile" "worker_node_instance_profile" {
  name = "${var.cluster_name}-node-role"
  role = aws_iam_role.worker_node_role.name
}

resource "aws_eks_node_group" "cpu-worker-nodes" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.worker_node_role.arn
  subnet_ids      = var.private_subnet_id
  ami_type        = var.ami_type # possible values [AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64]
  capacity_type   = var.capacity_type #Valid Values [ON_DEMAND, SPOT]
  instance_types  = var.instance_types
  disk_size       = "300"
  labels          = var.labels #key-value map
  # tags            = var.tags #key-value map

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  update_config {
      max_unavailable = 1
    }
  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # remote_access {
  #   source_security_group_ids  = [aws_security_group.worker_node_sg.id]
  #   ec2_ssh_key                = var.ssh_key_name
  # }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AutoScalingFullAccess,
    aws_iam_role_policy_attachment.ElasticLoadBalancingFullAccess,
    var.cluster_create_wait
  ]
}
