variable "vpc_id" {
  description = "the vpc id for cluster"
}
variable "node_sg" {
  description = "Id of Security group that EKS worker nodes will use"
}
variable "cluster_name" {
  description = "Name to give your eks cluster"
}
variable "private_subnet_ids" {
  #type        = list(string)
  description = "List of subnets that EKS contol plane will deploy ENI to"
}
# variable "cluster_enpoint_cidr" {
# #  type        = list(string)
#   description = "Cidrs to provide to access kubernetes api server"
# }
variable "cluster_sg_ids" {
  description = "list of security groups to provide to eks when creating cluster"
}

variable "cluster_version" {
  type        = string
  default     = ""
  description = "The desired eks cluster that the team needs. Team must make sure their desired EKS version exists"
}

variable "csi-role-name" {
  default = ""
}

# variable "bastion_host_sg" {
# default = "" 
# }


variable "private_access" {}

variable "public_access" {}
