# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket-unique-name-123"

  tags = {
    project     = "Datalake-v2"
    env         = "production"
    Owner       = "DevOps Team"
    # cost-center = "12345"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}