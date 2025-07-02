## EKS Cluster Security Group

resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS Cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}
resource "aws_security_group_rule" "self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.cluster_sg.id
}


#### Bastion Host Seurity Group
resource "aws_security_group" "bastion_host_sg" {
  name        = var.bastion_sg_name
  description = "Security group for the bastion host"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "bastion_host"
  }
}
resource "aws_security_group_rule" "bastion_host" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_host_sg.id
  security_group_id        = aws_security_group.cluster_sg.id
}

## NODES SECURITY GROUPS
## CPU Security Group
resource "aws_security_group" "worker_node_sg" {
  name        = "${var.cluster_name}-cp-node-sg"
  description = "Security group for EKS worker nodes also grants ssh access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cpu-node-sg"
  }
}

resource "aws_security_group_rule" "worker-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.worker_node_sg.id
}

resource "aws_security_group_rule" "cluster-access" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster_sg.id
  security_group_id        = aws_security_group.worker_node_sg.id
}



# GPU Security Group
resource "aws_security_group" "gpu_node_sg" {
  name        = "${var.cluster_name}-gpu-node-sg"
  description = "Security group for EKS gpu nodes also grants ssh access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-gpu-node-sg"
  }
}
resource "aws_security_group_rule" "gpu-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.gpu_node_sg.id
}

resource "aws_security_group_rule" "cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster_sg.id
  security_group_id        = aws_security_group.gpu_node_sg.id
}

# resource "aws_security_group_rule" "ssh_access" {
#   cidr_blocks       = [local.workstation-external-cidr]
#   description       = "Allow ssh access from local computer"
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.gpu_node_sg.id
#   to_port           = 22
#   type              = "ingress"
# }


## Karpenter Security Group

resource "aws_security_group" "karp_node_sg" {
  name        = "${var.cluster_name}-karp-sg"
  description = "Security group for EKS karp nodes also grants ssh access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "karp_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.karp_node_sg.id
}

resource "aws_security_group_rule" "karpenter" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster_sg.id
  security_group_id        = aws_security_group.karp_node_sg.id
}


## RDS Security Group
resource "aws_security_group" "allow_postgres_traffic" {
  name           = var.rds-sg-name
  description    = "Allow Postgres traffic"
  vpc_id         = var.vpc_id

  ingress {
    description  = "allow Postgres"
    from_port    = 5432
    to_port      = 5432
    protocol     = "tcp"
    cidr_blocks  = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.rds-sg-name
  }
}

resource "aws_security_group_rule" "rds-sg" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.allow_postgres_traffic.id
  security_group_id        = aws_security_group.cluster_sg.id
}
