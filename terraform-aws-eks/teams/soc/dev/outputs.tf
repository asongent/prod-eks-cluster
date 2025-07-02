output "vpc_id" {
  value = module.vpc.vpc_id
}
# output "bh-public_ip" {
#   value = module.bastion-host.bastion_host
# }
# output "postgres-endpoint" {
#   value = module.postgres.rds_id
# }
output "cluster_endpoint" {
  value = module.eks_cluster.endpoint
}

# output "vpc_name" {
#   value = var.vpc_name
# }


# output "region" {
#   description = "AWS region"
#   value       =  var.region
# }

# output "bastion_host_security_group_id" {
#   value = module.eks_cluster.bastion_host_security_group_id
# }

# output "cluster_name" {
#   value = var.cluster_name
# }