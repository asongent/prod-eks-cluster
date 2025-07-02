resource "aws_iam_role" "gpu_node_role" {
  name               = "gpu-node-role" 

  assume_role_policy = jsonencode({
    Statement        = [{
      Action         = "sts:AssumeRole"
      Effect         = "Allow"
      Principal      = {
        Service      = "ec2.amazonaws.com"
      }
    }]
    Version          = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "gpu-node-group" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.gpu_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.gpu_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.gpu_node_role.name
}

resource "aws_iam_role_policy_attachment" "AutoScalingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = aws_iam_role.gpu_node_role.name
}

resource "aws_iam_role_policy_attachment" "ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.gpu_node_role.name
}

resource "aws_iam_instance_profile" "gpu_node_instance_profile" {
  name = "${var.gpu_group_name}-node-role"
  role = aws_iam_role.gpu_node_role.name
}

# resource "aws_security_group" "gpu_node_sg" {
#   name        = "${var.gpu_group_name}-sg"
#   description = "Security group for EKS gpu nodes also grants ssh access"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.cluster_name}-gpu-node-sg"
#   }
# }

# resource "aws_security_group_rule" "self" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   self              = true
#   security_group_id = aws_security_group.gpu_node_sg.id
# }

# resource "aws_security_group_rule" "cluster" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   source_security_group_id = var.cluster_sg
#   security_group_id = aws_security_group.gpu_node_sg.id
# }

# resource "aws_security_group_rule" "ssh_access" {
#   cidr_blocks       = [local.workstation-external-cidr]
#   description       = "Allow ssh access from local computer"
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.gpu_node_sg.id
#   to_port           = 22
#   type              = "ingress"
# }

resource "aws_eks_node_group" "gpu-worker-nodes" {
  cluster_name    = var.cluster_name
  node_group_name = var.gpu_group_name
  node_role_arn   = aws_iam_role.gpu_node_role.arn 
  subnet_ids      = var.private_subnet_id
  ami_type        = var.ami_type 
  capacity_type   = var.capacity_type #Valid Values [ON_DEMAND, SPOT]
  instance_types  = var.instance_types
  disk_size       = 200
  labels          = var.labels 
  taint {
    key = "soc-instance"
    value  = "soc-application"
    effect = "NO_SCHEDULE"
  }

  scaling_config {
    desired_size = var.gpu_desired_size
    max_size     = var.gpu_max_size
    min_size     = var.gpu_min_size
    
  }

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.gpu-node-group,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AutoScalingFullAccess,
    aws_iam_role_policy_attachment.ElasticLoadBalancingFullAccess,
    var.cluster_create_wait
  ]
}
