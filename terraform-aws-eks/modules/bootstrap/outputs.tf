output "s3_state_bucket" {
  value = aws_s3_bucket.tf-state-bucket.id
}

output "lock_table" {
  value = aws_dynamodb_table.soc-dblock-table.id
}

output "log_bucket" {
  value = aws_s3_bucket.log_bucket.id
}
