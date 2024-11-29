
variable "instance_type" {
  description = "This will depend on team's preference and availability"
}

variable "ami_type" {
  description = "AMI Type for node group selecect from - [AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64]"
}

variable "vpc_id" {
  description = "VPC Id"
}


variable "public_subnet_id" {
  type        = string
  description = "public subnet where the bastion host will be deployed"
}

variable "ami_id" {
  description = "chose instance type base on you preference"
  default = ""
}

variable "key_name" {
  default = ""
}

variable "subnet_id" {
  description = "public subnet where the bastion host will be deployed"
}

variable "bastion-host_name" {
  default = ""
}

variable "vpc_security_group_ids"{}
