
variable "cluster_name" {
  description = "Name to give your eks cluster"
}
variable "vpc_id" {
  description = "the vpc id for cluster"
}

variable "bastion_sg_name" {}
variable "rds-sg-name" {}
variable "vpc_cidr" {
  type = string
}