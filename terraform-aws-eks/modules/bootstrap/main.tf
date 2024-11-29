locals {
  bucket_id     = "${var.account}-${var.region}-terraform-state"
  log_bucket_id = "${var.account}-${var.region}-terraform-state-logs"
}


###### Log Buckets
resource "aws_s3_bucket" "log_bucket" {
  bucket = local.log_bucket_id
  tags = {
    provisioner  = "Terraform"
    Name         = local.log_bucket_id
    Contact      = var.tag_email
    Resource_POC = var.tag_name
    Application  = "SOC"
    Description  = "Bucket for logging terraform state file bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  bucket = local.log_bucket_id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket]
  bucket = local.log_bucket_id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_log_bucket" {
  bucket = local.log_bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}
### Ends
resource "aws_dynamodb_table" "soc-dblock-table" {
  name           = "soc-statefile-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    provisioner  = "Terraform"
    Name         = "soc-statefile-lock"
    Contact      = var.tag_email
    Resource_POC = var.tag_name
    Application  = "SOC"
    Description  = "SOC IAC Terraform lock Table"
  }
}

resource "aws_s3_bucket" "tf-state-bucket" {
  bucket = local.bucket_id
  /* acl    = "private" */
  tags = {
    provisioner  = "Terraform"
    Name         = local.bucket_id
    Contact      = var.tag_email
    Resource_POC = var.tag_name
    Application  = "SOC"
    Description  = "Bucket for storing SOC IAC State files"
  }
}
## Adding supported features
resource "aws_s3_bucket_ownership_controls" "tf-state-bucket" {
  bucket = local.bucket_id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf-state-bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.tf-state-bucket]
  bucket = local.bucket_id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_tf-state-bucket" {
  bucket = local.bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/local.bucket_id"
}

