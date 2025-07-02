#Network Variables
variable "region" {
  default = ""
}
variable "vpc_name" {
  default = ""
}
variable "vpc_cidr" {
  type = string
}

#Cluster Configuration
variable "cluster_name" {
  default = ""
}
variable "cluster_version" {
  type        = string
  default     = ""
  description = "The desired eks cluster that the team needs. Team must make sure their desired EKS version exists"
}

variable "node_group_name" {
  default = ""
}

variable "ami" {
  type    = string
  default = "AL2_x86_64"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "bastion_host_name" {
  default = "public_ip"
}

### Additional variables for node groups
variable "desired_size" {
  type        = number
  description = "desired node count for cluster node group"
}
variable "max_size" {
  type        = number
  description = "Max size for nodes in the node group"
}
variable "min_size" {
  type        = number
  description = "Min size for nodes in the node group"
}

### Additional variables for node groups
## GPU

variable "gpu_group_name" {
  description = "EKS node group name"
}

variable "gpu_desired_size" {
  type        = number
  description = "desired node count for cluster node group"
}
variable "gpu_max_size" {
  type        = number
  description = "Max size for nodes in the node group"
}
variable "gpu_min_size" {
  type        = number
  description = "Min size for nodes in the node group"
}


## Bastion Host
variable "key_name" {
  default = ""
}

variable "aws_eks_cluster" {
  default = ""
}

variable "csi-role-name" {
  default = ""
}

variable "bastion-host_name" {
  default = ""
}

###backend
variable "dynamodb_table-name" {

  default = ""
}

variable "s3-bucket-name" {
  default = ""
}

variable "account_id" {
  type = number
}
# variable "eks-pod-identity" {
#   default = ""
# }
variable "bastion_host_sg" {
  default = ""
}

variable "ami_id" {
  description = "chose instance type base on you preference"
  default     = ""
}


variable "private_access" {}
variable "public_access" {}

##RDS Details
variable "identifier" {}
variable "rds-sg-name" {}
variable "engine_type" {}
variable "rds_instance_class" {}
variable "user_name" {
  default = ""
}
variable "db_password" {
  default = ""
}
variable "storage" {
  default = ""
}
variable "engine_version" {
  default = ""
}
variable "publicly_accessible" {}
variable "snapshot" {}

variable "bastion_sg_name" {}

# variable "private_subnet_id" {}
# variable "vpc_id" {}
# variable "vpc_security_group_ids" {}


### Karpenter
variable "Karp_ng_name" {
  description = "Name of EKS node to hold karpenter"
}

variable "desired" {
  type        = number
  description = "desired node count for cluster node group"
}
variable "max" {
  type        = number
  description = "Max size for nodes in the node group"
}
variable "min" {
  type        = number
  description = "Min size for nodes in the node group"
}