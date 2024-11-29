output "worker_node_role_arn" {
  value = aws_iam_role.worker_node_role.arn
}
output "worker_node_role_id" {
  value = aws_iam_role.worker_node_role.id
}
output "node_sg_id" {
  value = aws_security_group.worker_node_sg.id
}
output "node_sg_name" {
  value = aws_security_group.worker_node_sg.name
}
