
output "subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}


output "rds_id" {
  value = aws_db_instance.postgres.endpoint
}
