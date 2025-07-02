locals {
  subnet_cidr_priv = cidrsubnets(var.vpc_cidr, 2, 2, 2, 2, )
}
locals {
  subnet_cidr_pub = cidrsubnets(local.subnet_cidr_priv[2], 2, 2, 2, 2, )
}
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source         = "../../../modules/vpc"
  cidr_block_vpc = var.vpc_cidr
  vpc_name       = var.vpc_name
}

module "subnet" {
  count                  = 2
  source                 = "../../../modules/subnet"
  vpc_id                 = module.vpc.vpc_id
  cidr_block_subnet_pub  = local.subnet_cidr_pub[count.index]                       #var.cidr_pub[count.index]
  cidr_block_subnet_priv = local.subnet_cidr_priv[count.index]                      #var.cidr_priv[count.index]
  availability_zone      = data.aws_availability_zones.available.names[count.index] #var.azs[count.index]
  vpc_name               = var.vpc_name
  public_route_table     = module.vpc.public_route_table_id
  cluster_name           = var.cluster_name

}
module "security_group" {
  source             = "../../../modules/security-groups"
  bastion_sg_name    = var.bastion_sg_name
  cluster_name       = var.cluster_name
  rds-sg-name        = var.rds-sg-name
  vpc_cidr           = var.vpc_cidr
  vpc_id             = module.vpc.vpc_id
}
module "eks_cluster" {
  source             = "../../../modules/eks_cluster"
  vpc_id             = module.vpc.vpc_id
  node_sg            = module.security_group.node_sg_id
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  private_access     = var.private_access
  public_access      = var.public_access
  private_subnet_ids = concat(module.subnet[*].private_subnet, module.subnet[*].public_subnet)
  cluster_sg_ids     = [module.security_group.cluster_sg_id, module.security_group.node_sg_id]
}

module "addons" {
  source       = "../../../modules/eks-addons"
  cluster_name = var.cluster_name
  depends_on   = [module.eks_node_group]
}

module "pod_identity" {
  source       = "../../../modules/pod-identity"
  cluster_name = var.cluster_name
  depends_on   = [module.eks_cluster]
}

module "karpenter" {
  source              = "../../../modules/karpenter_node"
  Karp_ng_name        = var.Karp_ng_name
  vpc_id              = module.vpc.vpc_id
  cluster_sg          = module.security_group.cluster_sg_id
  cluster_name        = var.cluster_name
  private_subnet_id   = module.subnet[*].private_subnet
  desired             = var.desired
  max                 = var.max
  min                 = var.min
  ami_type            = "AL2_x86_64"
  capacity_type       = "ON_DEMAND"
  instance_types      = ["t3.medium"]
  labels              = { node = "karpenter", type = "on_demand" }
  cluster_create_wait = module.eks_cluster.endpoint
  depends_on          = [module.eks_cluster]
}
module "eks_node_group" {
  source              = "../../../modules/eks_node_group"
  vpc_id              = module.vpc.vpc_id
  cluster_sg          = module.security_group.cluster_sg_id
  cluster_name        = var.cluster_name
  node_group_name     = var.node_group_name
  private_subnet_id   = module.subnet[*].private_subnet
  desired_size        = var.desired_size
  max_size            = var.max_size
  min_size            = var.min_size
  ami_type            = "AL2_x86_64"
  capacity_type       = "ON_DEMAND"
  instance_types      = ["t3.medium", "t2.medium", "m7i.2xlarge", "m5n.xlarge", "m5d.xlarge", "m5dn.xlarge", "m5a.xlarge", "m4.xlarge"] #["m7i.2xlarge"] 
  labels              = { node = "vcpu", type = "on_demand" }
  cluster_create_wait = module.eks_cluster.endpoint
  depends_on          = [module.eks_cluster]

}

# module "gpu_node_group" {
#   source              = "../../../modules/gpu_node_group"
#   vpc_id              = module.vpc.vpc_id
#  # cluster_sg         = module.eks_cluster.cluster_sg_id
#   cluster_sg          = module.security_group.cluster_sg_id
#   cluster_name        = var.cluster_name
#   gpu_group_name      = var.gpu_group_name
#   labels              = { node = "gpu", type = "spot" }
#   ami_type            = "AL2_x86_64_GPU"
#   capacity_type       = "ON_DEMAND"
#   instance_types      = ["g5.16xlarge, g5.2xlarge, g5.24xlarge, g3.8xlarge, g3.4xlarge"]
#   gpu_desired_size    = var.gpu_desired_size
#   gpu_min_size        = var.gpu_min_size
#   gpu_max_size        = var.gpu_max_size
#   private_subnet_id   = module.subnet[*].private_subnet
#   cluster_create_wait = module.eks_cluster.endpoint
#   depends_on   = [module.eks_cluster]
# }

# module "postgres" {
#   source              = "../../../modules/rds-postgres"
#   cluster_name        = var.cluster_name
#   cluster_sg          = module.security_group.cluster_sg_id
#   vpc_name            = var.vpc_name
#   storage             = var.storage
#   engine_type         = var.engine_type
#   engine_version      = var.engine_version
#   rds_instance_class  = var.rds_instance_class
#   identifier          = var.identifier
#   publicly_accessible = var.publicly_accessible
#   user_name           = var.user_name
#   db_password         = var.db_password
#   vpc_cidr            = module.vpc.vpc_id
#   snapshot            = var.snapshot
#   private_subnet_id   = module.subnet[*].private_subnet
#   vpc_id              = module.vpc.vpc_id
#   depends_on          = [module.vpc, module.subnet]
#   rds_sg_id           = module.security_group.rds_sg_id

# }

# module "bastion-host" {
#   source                 = "../../../modules/bastion-host"
#   vpc_id                 = module.vpc.vpc_id
#   subnet_id              = module.subnet[1].public_subnet
#   public_subnet_id       = module.subnet[1].public_subnet
#   instance_type          = var.instance_type
#   vpc_security_group_ids = module.security_group.bastion_host_security_group_id
#   key_name               = var.key_name
#   ami_type               = var.ami
#   ami_id                 = var.ami_id
#   depends_on             = [module.eks_cluster]
# }