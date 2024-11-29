output "Bucket_name" {
  value = module.bootstrap.s3_state_bucket
}
output "DynamoDb_table_name" {
  value = module.bootstrap.lock_table
}
output "log_bucket_name" {
  value = module.bootstrap.log_bucket
}
