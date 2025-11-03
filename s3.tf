# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket-unique-name-123"

  tags = {
    Name = "Application Bucket"
  }
}