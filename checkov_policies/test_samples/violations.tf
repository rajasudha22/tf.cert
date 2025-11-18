# Test file containing intentional policy violations
# Use this to verify that Checkov custom policies are working correctly

# VIOLATION 1: S3 bucket with public-read ACL
# Expected to FAIL: CKV_AWS_CUSTOM_001 (S3 Bucket Public Access Prevention)
# Severity: CRITICAL
resource "aws_s3_bucket" "public_read_bucket" {
  bucket = "test-public-read-bucket"
  acl    = "public-read"  # ❌ VIOLATION
}

# VIOLATION 2: S3 bucket with public-read-write ACL
# Expected to FAIL: CKV_AWS_CUSTOM_001 (S3 Bucket Public Access Prevention)
# Severity: CRITICAL
resource "aws_s3_bucket" "public_write_bucket" {
  bucket = "test-public-write-bucket"
  acl    = "public-read-write"  # ❌ VIOLATION
}

# VIOLATION 3: S3 bucket with authenticated-read ACL
# Expected to FAIL: CKV_AWS_CUSTOM_001 (S3 Bucket Public Access Prevention)
# Severity: CRITICAL
resource "aws_s3_bucket" "authenticated_read_bucket" {
  bucket = "test-authenticated-bucket"
  acl    = "authenticated-read"  # ❌ VIOLATION
}

# VIOLATION 4: EC2 instance without encryption
# Expected to FAIL: CKV_AWS_CUSTOM_002 (EC2 Instance Encryption)
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: HIGH, MEDIUM
resource "aws_instance" "unencrypted_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  # ❌ No encryption specified
  # ❌ No tags specified
}

# VIOLATION 5: EC2 instance with explicitly disabled encryption
# Expected to FAIL: CKV_AWS_CUSTOM_002 (EC2 Instance Encryption)
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: HIGH, MEDIUM
resource "aws_instance" "explicitly_unencrypted" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted = false  # ❌ VIOLATION
  }
  
  tags = {
    Name = "Test Server"  # ❌ Missing Environment, Owner, Project
  }
}

# VIOLATION 6: S3 bucket without required tags
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: MEDIUM
resource "aws_s3_bucket" "bucket_no_tags" {
  bucket = "test-bucket-no-tags"
  # ❌ No tags defined
}

# VIOLATION 7: S3 bucket with incomplete tags
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: MEDIUM
resource "aws_s3_bucket" "bucket_incomplete_tags" {
  bucket = "test-bucket-incomplete-tags"
  
  tags = {
    Name        = "Incomplete Tags Bucket"
    Environment = "dev"
    # ❌ Missing Owner and Project tags
  }
}

# VIOLATION 8: EC2 instance with partial encryption (root encrypted, EBS not)
# Expected to FAIL: CKV_AWS_CUSTOM_002 (EC2 Instance Encryption)
# Severity: HIGH
resource "aws_instance" "partial_encryption" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted = true  # ✓ Encrypted
  }
  
  ebs_block_device {
    device_name = "/dev/sdf"
    encrypted   = false  # ❌ VIOLATION
    volume_size = 20
  }
  
  tags = {
    Environment = "dev"
    Owner       = "DevOps"
    Project     = "Test"
  }
}

# VIOLATION 9: VPC without required tags
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: MEDIUM
resource "aws_vpc" "vpc_no_tags" {
  cidr_block = "10.0.0.0/16"
  # ❌ No tags defined
}

# VIOLATION 10: Lambda function without required tags
# Expected to FAIL: CKV_AWS_CUSTOM_003 (Resource Default Tags)
# Severity: MEDIUM
resource "aws_lambda_function" "lambda_no_tags" {
  filename      = "lambda.zip"
  function_name = "test_function"
  role          = "arn:aws:iam::123456789012:role/lambda_role"
  handler       = "index.handler"
  runtime       = "python3.9"
  # ❌ No tags defined
}