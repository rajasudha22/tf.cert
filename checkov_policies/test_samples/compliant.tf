# Test file containing compliant configurations
# Use this to verify that Checkov custom policies correctly pass valid configurations

# COMPLIANT 1: S3 bucket with private access (default)
# Expected to PASS: CKV_AWS_CUSTOM_001, CKV_AWS_CUSTOM_003
resource "aws_s3_bucket" "private_bucket" {
  bucket = "test-private-bucket"
  # No ACL specified - defaults to private ✓
  
  tags = {
    Name        = "Private Application Bucket"
    Environment = "production"  # ✓ Required tag
    Owner       = "DevOps Team" # ✓ Required tag
    Project     = "WebApp"      # ✓ Required tag
  }
}

# COMPLIANT 2: S3 bucket with explicit private ACL
# Expected to PASS: CKV_AWS_CUSTOM_001, CKV_AWS_CUSTOM_003
resource "aws_s3_bucket" "explicit_private" {
  bucket = "test-explicit-private-bucket"
  acl    = "private"  # ✓ Explicitly private
  
  tags = {
    Name        = "Explicit Private Bucket"
    Environment = "development"
    Owner       = "Development Team"
    Project     = "DataLake"
  }
}

# COMPLIANT 3: S3 bucket with public access block
# Expected to PASS: CKV_AWS_CUSTOM_001, CKV_AWS_CUSTOM_003
resource "aws_s3_bucket" "secured_bucket" {
  bucket = "test-secured-bucket"
  
  tags = {
    Name        = "Secured Bucket"
    Environment = "production"
    Owner       = "Security Team"
    Project     = "ComplianceData"
  }
}

resource "aws_s3_bucket_public_access_block" "secured_bucket_block" {
  bucket = aws_s3_bucket.secured_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# COMPLIANT 4: EC2 instance with encrypted root volume
# Expected to PASS: CKV_AWS_CUSTOM_002, CKV_AWS_CUSTOM_003
resource "aws_instance" "encrypted_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted   = true  # ✓ Encryption enabled
    volume_size = 20
    volume_type = "gp3"
  }
  
  tags = {
    Name        = "Encrypted Application Server"
    Environment = "production"
    Owner       = "Platform Team"
    Project     = "CoreServices"
  }
}

# COMPLIANT 5: EC2 instance with encrypted root and EBS volumes
# Expected to PASS: CKV_AWS_CUSTOM_002, CKV_AWS_CUSTOM_003
resource "aws_instance" "fully_encrypted" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"
  
  root_block_device {
    encrypted   = true  # ✓ Root encrypted
    kms_key_id  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    volume_size = 30
  }
  
  ebs_block_device {
    device_name = "/dev/sdf"
    encrypted   = true  # ✓ EBS encrypted
    kms_key_id  = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    volume_size = 100
  }
  
  ebs_block_device {
    device_name = "/dev/sdg"
    encrypted   = true  # ✓ EBS encrypted
    volume_size = 50
  }
  
  tags = {
    Name        = "Fully Encrypted Database Server"
    Environment = "production"
    Owner       = "Database Team"
    Project     = "CustomerData"
    CostCenter  = "Engineering"  # Optional additional tag
  }
}

# COMPLIANT 6: VPC with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_vpc" "compliant_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "Production VPC"
    Environment = "production"
    Owner       = "Network Team"
    Project     = "Infrastructure"
  }
}

# COMPLIANT 7: Subnet with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_subnet" "compliant_subnet" {
  vpc_id            = aws_vpc.compliant_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name        = "Public Subnet 1"
    Environment = "production"
    Owner       = "Network Team"
    Project     = "Infrastructure"
    Tier        = "Public"  # Optional additional tag
  }
}

# COMPLIANT 8: Security Group with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_security_group" "compliant_sg" {
  name        = "compliant-sg"
  description = "Security group with proper tagging"
  vpc_id      = aws_vpc.compliant_vpc.id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "Application Security Group"
    Environment = "production"
    Owner       = "Security Team"
    Project     = "WebApp"
  }
}

# COMPLIANT 9: Lambda function with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_lambda_function" "compliant_lambda" {
  filename      = "lambda.zip"
  function_name = "compliant_function"
  role          = "arn:aws:iam::123456789012:role/lambda_execution_role"
  handler       = "index.handler"
  runtime       = "python3.11"
  
  tags = {
    Name        = "Data Processing Function"
    Environment = "production"
    Owner       = "Data Team"
    Project     = "Analytics"
  }
}

# COMPLIANT 10: IAM Role with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_iam_role" "compliant_role" {
  name = "compliant-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name        = "Lambda Execution Role"
    Environment = "production"
    Owner       = "Platform Team"
    Project     = "ServerlessApps"
  }
}

# COMPLIANT 11: EBS Volume with encryption and tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_ebs_volume" "compliant_volume" {
  availability_zone = "us-east-1a"
  size              = 100
  encrypted         = true
  kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  tags = {
    Name        = "Data Volume"
    Environment = "production"
    Owner       = "Storage Team"
    Project     = "DataWarehouse"
  }
}

# COMPLIANT 12: RDS Instance with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_db_instance" "compliant_db" {
  identifier           = "compliant-db"
  engine              = "postgres"
  engine_version      = "14.7"
  instance_class      = "db.t3.medium"
  allocated_storage   = 100
  storage_encrypted   = true
  
  tags = {
    Name        = "Production Database"
    Environment = "production"
    Owner       = "Database Team"
    Project     = "CustomerManagement"
  }
}

# COMPLIANT 13: CloudWatch Log Group with all required tags
# Expected to PASS: CKV_AWS_CUSTOM_003
resource "aws_cloudwatch_log_group" "compliant_logs" {
  name              = "/aws/lambda/compliant-function"
  retention_in_days = 30
  
  tags = {
    Name        = "Lambda Function Logs"
    Environment = "production"
    Owner       = "Platform Team"
    Project     = "Monitoring"
  }
}