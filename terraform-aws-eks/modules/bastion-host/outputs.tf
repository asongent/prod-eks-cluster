output "bastion_host" {
  value = aws_instance.bastion_host.public_ip
}

# output "bh-public_ip" {
#   value = module.eks_cluster.bastion_host_security_group_id
# }