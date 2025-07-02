
variable "vpc_id" {
  description = "vpc cidr block"
}
variable "cluster_sg" {}


variable "rds_instance_class" {}
variable "user_name" {}
variable "identifier" {}
variable "db_password" {}

variable "engine_type" {
  default = ""
}

variable "rds_sg_id" {
  
}
variable "storage" {}

variable "vpc_name" {}
variable "vpc_cidr" {
  type = string
}
variable "cluster_name" {}
# variable "availability_zone" {}
variable "publicly_accessible" {}
variable "engine_version" {}
variable "snapshot" {}
variable "private_subnet_id" {}
# variable "vpc_security_group_ids" {}