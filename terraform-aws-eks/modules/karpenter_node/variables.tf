variable "vpc_id" {
  description = "VPC Id"
}
variable "cluster_sg" {
  description = "Cluster Security Group Id"
}
variable "cluster_name" {
  description = "EKS Cluster name"
}
variable "Karp_ng_name" {}
variable "private_subnet_id" {
  type        = list(string)
  description = "List of subnets to deploy node groups - this should be a list of private subnets"
}
# possible values [AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64]
variable "ami_type" {
  description = "AMI Type for node group selecect from - [AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64]"
}
#Valid Values [ON_DEMAND, SPOT]
variable "capacity_type" {
  description = "Instance capacity type either ON_DEMAND, SPOT, OR RESERVED "
}
variable "instance_types" {
  description = "Select type of instance, t2.micro, m5.large etc."
}
variable "cluster_create_wait" {
  description = "wait for cluster creation"
}
variable "labels" {
  type        = map(string)
  description = "List of subnets that EKS contol plane will deploy ENI to"
}
# variable "tags" {
#   type        = map(string)
#   description = "Tags to apply to eks nodegroups"
# }
variable "desired" {
  type = number
  description = "desired node count for cluster node group"
}
variable "max" {
  type = number
  description = "Max size for nodes in the node group"
}
variable "min" {
  type = number
  description = "Min size for nodes in the node group"
}

# variable "ssh_key_name" {
#   description = "name of ssh key to use"
# }
