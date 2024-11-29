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

module "eks_cluster" {
  source          = "../../../modules/eks_cluster"
  vpc_id          = module.vpc.vpc_id
  node_sg         = module.eks_node_group.node_sg_id
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  /* private_subnet_ids = concat(module.subnet[*].private_subnet, module.subnet[*].public_subnet) #original */
  private_subnet_ids = concat(module.subnet[*].private_subnet, module.subnet[*].public_subnet) #testing
  cluster_sg_ids     = [module.eks_cluster.cluster_sg_id, module.eks_node_group.node_sg_id]
  # csi-role-name      = var.csi-role-name
}


module "eks_node_group" {
  source              = "../../../modules/eks_node_group"
  vpc_id              = module.vpc.vpc_id
  cluster_sg          = module.eks_cluster.cluster_sg_id
  cluster_name        = var.cluster_name
  node_group_name     = var.node_group_name
  private_subnet_id   = module.subnet[*].private_subnet
  desired_size        = var.desired_size
  max_size            = var.max_size
  min_size            = var.min_size
  ami_type            = "AL2_x86_64"
  capacity_type       = "ON_DEMAND"
  instance_types      = ["m7i.2xlarge"] #["t3.medium", "t2.medium", "m5n.xlarge", "m5d.xlarge", "m5dn.xlarge", "m5a.xlarge", "m4.xlarge"]
  labels              = { node = "vcpu", type = "on_demand" }
  cluster_create_wait = module.eks_cluster.endpoint

}



# module "gpu_node_group" {
#   source              = "../../../modules/gpu_node_group"
#   vpc_id              = module.vpc.vpc_id
#   cluster_sg          = module.eks_cluster.cluster_sg_id
#   cluster_name        = var.cluster_name
#   gpu_group_name      = var.gpu_group_name
#   labels              = { node = "gpu", type = "spot" }
#   ami_type            = "AL2_x86_64_GPU"
#   capacity_type       = "SPOT"
#   instance_types      = ["g5.16xlarge, g5.2xlarge, g5.24xlarge, g3.8xlarge, g3.4xlarge"]
#   gpu_desired_size    = var.gpu_desired_size
#   gpu_min_size        = var.gpu_min_size
#   gpu_max_size        = var.gpu_max_size
#   private_subnet_id   = module.subnet[*].private_subnet
#   cluster_create_wait = module.eks_cluster.endpoint
# }
module "addons" {
  source       = "../../../modules/eks-addons"
  cluster_name = var.cluster_name
  depends_on   = [module.eks_cluster]
}

module "pod_identity" {
  source       = "../../../modules/pod-identity"
  cluster_name = var.cluster_name
  depends_on   = [module.eks_cluster]
}


module "bastion-host" {
  source                 = "../../../modules/bastion-host"
  vpc_id                 = module.vpc.vpc_id
  subnet_id              = module.subnet[1].public_subnet
  public_subnet_id       = module.subnet[1].public_subnet
  instance_type          = var.instance_type
  vpc_security_group_ids = module.eks_cluster.bastion_host_security_group_id
  key_name               = var.key_name
  ami_type               = var.ami
  ami_id                 = var.ami_id
}