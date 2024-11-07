# Create the primary S3 bucket for the data lake
resource "aws_s3_bucket" "data_lake" {
  bucket = var.data_lake_bucket_name

  tags = {
    Name        = var.data_lake_bucket_name
    Environment = var.environment
  }
}

# Enable versioning to preserve data integrity for data lake
resource "aws_s3_bucket_versioning" "datalake_versioning" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption to protect data at rest (conditionally apply KMS or AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "server_side_encryption" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_sse_kms ? "aws:kms" : "AES256"
      # Conditionally apply KMS key if using KMS encryption
      kms_master_key_id = var.enable_sse_kms ? aws_kms_key.mykey.arn : null
    }
  }
}

# Create the logging bucket (to store access logs)
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.logging_bucket_name

  tags = {
    Name        = "log-bucket"
    Environment = var.environment
  }
}

# Enable versioning to preserve data integrity for log bucket
resource "aws_s3_bucket_versioning" "logbucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Apply appropriate permissions to the logging bucket
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

# Conditionally set up logging for the data lake bucket
resource "aws_s3_bucket_logging" "data_lake_logging" {
  count = var.enable_logging ? 1 : 0  # Logging is conditional

  bucket        = aws_s3_bucket.data_lake.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "logs/"
}

# S3 Object for raw data directory
resource "aws_s3_object" "raw_data_directory" {
  bucket  = aws_s3_bucket.data_lake.bucket
  key     = "raw/"
  content = ""
}

# S3 Object for processed data directory
resource "aws_s3_object" "processed_data_directory" {
  bucket  = aws_s3_bucket.data_lake.bucket
  key     = "processed/"
  content = ""
}

# S3 Bucket Policy to allow access from Glue, Lambda, etc.
resource "aws_s3_bucket_policy" "data_lake_policy" {
  bucket = aws_s3_bucket.data_lake.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.iam_roles
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.data_lake.arn}",
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
      }
    ]
  })
}

# Lifecycle policy to transition data to Glacier after specified days
resource "aws_s3_bucket_lifecycle_configuration" "data_lake_lifecycle" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "Transition to Glacier"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    transition {
      days          = var.lifecycle_transition_days
      storage_class = "GLACIER"
    }
  }
}
