
# IAM Role
resource "aws_iam_role" "ec2_s3_access" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "EC2 S3 Access Role"
    env         = "production"
    Owner       = "Devops Team"
    project     = "WebApp"
    cost-center = "67890"
  }
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_s3_access.name

  tags = {
    Name        = "EC2 Instance Profile"
    env         = "production"
    Owner       = "Devops Team"
    project     = "WebApp"
    cost-center = "67890"
  }
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Egress to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SSH Security Group"
    env         = "production"
    Owner       = "Platform Team"
    project     = "WebApp"
    cost-center = "67890"
  }
}

# EC2 Instance
# Data source to fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 Instance
# resource "aws_instance" "app_server" {
#   ami                    = data.aws_ami.amazon_linux_2.id
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public.id
#   iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
#   vpc_security_group_ids = [aws_security_group.allow_ssh.id]
#   monitoring             = true

#   root_block_device {
#     encrypted   = true
#     volume_type = "gp3"
#     volume_size = 20
#   }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#   }

#   tags = {
#     Name        = "AppServer"
#     env         = "production"
#     Owner       = "Platform Team"
#     project     = "WebApp"
#     cost-center = "67890"
#   }
# }

# Output Values
output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}