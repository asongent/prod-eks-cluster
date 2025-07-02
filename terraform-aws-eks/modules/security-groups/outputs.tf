## Cluster 

output "cluster_sg_id" {
  value = aws_security_group.cluster_sg.id
}

output "cluster_sg_name" {
  value = aws_security_group.cluster_sg.name
}


## Bastion Host 
output "bastion_host_security_group_id" {
  value = aws_security_group.bastion_host_sg.id
}

## CPU nodes
output "node_sg_id" {
  value = aws_security_group.worker_node_sg.id
}

output "node_sg_name" {
  value = aws_security_group.worker_node_sg.name
}

## RDS
output "rds_sg_id" {
  value = aws_security_group.allow_postgres_traffic.id
}

