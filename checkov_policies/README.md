# Checkov Custom Policies for Terraform (YAML Format)

This directory contains custom Checkov policies written in YAML format to enforce security and compliance standards for Terraform infrastructure code.

## Overview

These custom policies extend Checkov's built-in security checks with organization-specific requirements:

1. **S3 Bucket Public Access Prevention** (`CKV_AWS_CUSTOM_001`) - CRITICAL
2. **EC2 Instance Encryption** (`CKV_AWS_CUSTOM_002`) - HIGH
3. **Resource Default Tags** (`CKV_AWS_CUSTOM_003`) - MEDIUM

## Prerequisites

- Python 3.7 or higher
- Checkov installed (`pip install checkov`)

## Installation

The custom policies are located in the [`checkov_policies/`](.) directory as YAML files and will be automatically loaded when you run Checkov with the `--external-checks-dir` flag.

## Policy Files Structure

```
checkov_policies/
├── __init__.py
├── S3BucketNoPublicAccess.yaml       # S3 public access prevention
├── EC2InstanceEncryption.yaml        # EC2 encryption enforcement
├── ResourceDefaultTags.yaml          # Required tags enforcement
├── .checkov.yaml                     # Checkov configuration
├── run_checks.sh                     # Helper script to run checks
└── README.md                         # This file
```

## Usage

### Running Checkov with Custom Policies

To scan your Terraform code with these custom policies:

```bash
# Using the provided script (recommended)
./tf.cert/checkov_policies/run_checks.sh

# Or manually from the project root
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies

# Scan specific Terraform file
checkov -f tf.cert/main.tf --external-checks-dir tf.cert/checkov_policies

# Scan and output results to JSON
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies -o json

# Skip specific checks if needed
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies --skip-check CKV_AWS_CUSTOM_001

# Run only custom checks
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies --check CKV_AWS_CUSTOM_001,CKV_AWS_CUSTOM_002,CKV_AWS_CUSTOM_003
```

### Running in CI/CD Pipeline

Add to your CI/CD pipeline (GitHub Actions example):

```yaml
name: Checkov Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  checkov-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install Checkov
        run: pip install checkov
      
      - name: Run Checkov
        run: |
          checkov -d tf.cert \
            --external-checks-dir tf.cert/checkov_policies \
            --output json > checkov-results.json
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: checkov-results
          path: checkov-results.json
```

## Custom Policies

### 1. S3 Bucket Public Access Prevention (`CKV_AWS_CUSTOM_001`)

**Severity:** CRITICAL  
**File:** [`S3BucketNoPublicAccess.yaml`](S3BucketNoPublicAccess.yaml)

**Purpose:** Ensures S3 buckets are not publicly accessible.

**Checked Resources:**
- `aws_s3_bucket`

**What it checks:**
- Bucket ACL is not set to `public-read`, `public-read-write`, or `authenticated-read`
- Prevents accidental public exposure of sensitive data

**Example - Non-Compliant:**
```hcl
resource "aws_s3_bucket" "bad_example" {
  bucket = "my-public-bucket"
  acl    = "public-read"  # ❌ FAILS CHECK - CRITICAL
}

resource "aws_s3_bucket" "bad_example2" {
  bucket = "my-bucket"
  acl    = "public-read-write"  # ❌ FAILS CHECK - CRITICAL
}
```

**Example - Compliant:**
```hcl
resource "aws_s3_bucket" "good_example" {
  bucket = "my-private-bucket"
  # No ACL specified (defaults to private) ✅ PASSES
  
  tags = {
    Name        = "Private Bucket"
    Environment = "prod"
    Owner       = "DevOps"
    Project     = "MyApp"
  }
}

resource "aws_s3_bucket_public_access_block" "good_example" {
  bucket = aws_s3_bucket.good_example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 2. EC2 Instance Encryption (`CKV_AWS_CUSTOM_002`)

**Severity:** HIGH  
**File:** [`EC2InstanceEncryption.yaml`](EC2InstanceEncryption.yaml)

**Purpose:** Ensures EC2 instances have encrypted EBS volumes.

**Checked Resources:**
- `aws_instance`

**What it checks:**
- Root block device has encryption enabled
- All EBS block devices have encryption enabled

**Example - Non-Compliant:**
```hcl
resource "aws_instance" "bad_example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  # ❌ FAILS - No encryption specified - HIGH severity
}

resource "aws_instance" "bad_example2" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted = false  # ❌ FAILS CHECK - HIGH
  }
}
```

**Example - Compliant:**
```hcl
resource "aws_instance" "good_example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted   = true  # ✅ PASSES
    kms_key_id  = aws_kms_key.ebs.arn
    volume_size = 20
  }
  
  ebs_block_device {
    device_name = "/dev/sdf"
    encrypted   = true  # ✅ PASSES
    volume_size = 30
  }
  
  tags = {
    Name        = "WebServer"
    Environment = "production"
    Owner       = "DevOps"
    Project     = "WebApp"
  }
}
```

### 3. Resource Default Tags (`CKV_AWS_CUSTOM_003`)

**Severity:** MEDIUM  
**File:** [`ResourceDefaultTags.yaml`](ResourceDefaultTags.yaml)

**Purpose:** Ensures AWS resources have required default tags for governance and cost tracking.

**Checked Resources:**
- `aws_instance`
- `aws_s3_bucket`
- `aws_vpc`
- `aws_subnet`
- `aws_security_group`
- `aws_db_instance`
- `aws_iam_role`
- `aws_lambda_function`
- And 8+ more resource types

**Required Tags:**
- `Environment` (e.g., dev, staging, prod)
- `Owner` (e.g., team or individual responsible)
- `Project` (e.g., project or application name)

**Example - Non-Compliant:**
```hcl
resource "aws_instance" "bad_example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "WebServer"  # ❌ FAILS - Missing Environment, Owner, Project - MEDIUM
  }
}

resource "aws_s3_bucket" "bad_example" {
  bucket = "my-bucket"
  # ❌ FAILS - No tags defined - MEDIUM
}
```

**Example - Compliant:**
```hcl
resource "aws_instance" "good_example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name        = "WebServer"
    Environment = "production"  # ✅ Required
    Owner       = "DevOps Team" # ✅ Required
    Project     = "WebApp"      # ✅ Required
  }
}

resource "aws_s3_bucket" "good_example" {
  bucket = "my-app-bucket"
  
  tags = {
    Name        = "Application Bucket"
    Environment = "production"
    Owner       = "DevOps Team"
    Project     = "WebApp"
  }
}
```

## Testing the Policies

### Quick Test

Test the policies against your current Terraform code:

```bash
cd tf.cert
checkov -d . --external-checks-dir ./checkov_policies
```

### Test Against Sample Files

Create a test file to verify the policies work:

```bash
# Create a test directory
mkdir -p tf.cert/checkov_policies/test_samples

# Create test file with violations
cat > tf.cert/checkov_policies/test_samples/violations.tf << 'EOF'
# This file contains intentional violations for testing

# VIOLATION: S3 bucket with public ACL (CKV_AWS_CUSTOM_001)
resource "aws_s3_bucket" "public_bucket" {
  bucket = "test-public-bucket"
  acl    = "public-read"
}

# VIOLATION: EC2 without encryption (CKV_AWS_CUSTOM_002)
resource "aws_instance" "unencrypted" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

# VIOLATION: S3 bucket without required tags (CKV_AWS_CUSTOM_003)
resource "aws_s3_bucket" "no_tags" {
  bucket = "test-bucket-no-tags"
}
EOF

# Run Checkov against test file
checkov -f tf.cert/checkov_policies/test_samples/violations.tf \
  --external-checks-dir tf.cert/checkov_policies
```

Expected output should show 3 failures (one for each policy).

### Test Compliant Configuration

```bash
# Create compliant test file
cat > tf.cert/checkov_policies/test_samples/compliant.tf << 'EOF'
# This file contains compliant configurations

# COMPLIANT: S3 bucket (private by default)
resource "aws_s3_bucket" "private_bucket" {
  bucket = "test-private-bucket"
  
  tags = {
    Name        = "Private Bucket"
    Environment = "dev"
    Owner       = "DevOps"
    Project     = "Testing"
  }
}

# COMPLIANT: EC2 with encryption
resource "aws_instance" "encrypted" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted = true
  }
  
  tags = {
    Name        = "Test Server"
    Environment = "dev"
    Owner       = "DevOps"
    Project     = "Testing"
  }
}
EOF

# Run Checkov - should pass all checks
checkov -f tf.cert/checkov_policies/test_samples/compliant.tf \
  --external-checks-dir tf.cert/checkov_policies
```

## Customization

### Modifying Required Tags

To customize the required tags in [`ResourceDefaultTags.yaml`](ResourceDefaultTags.yaml), edit the definition section:

```yaml
definition:
  and:
    - cond_type: "attribute"
      attribute: "tags.Environment"
      operator: "exists"
    - cond_type: "attribute"
      attribute: "tags.Owner"
      operator: "exists"
    - cond_type: "attribute"
      attribute: "tags.CostCenter"  # Add new required tag
      operator: "exists"
```

### Adjusting Severity Levels

In each YAML file, update the `severity` field:
- `CRITICAL` - Must be fixed immediately
- `HIGH` - Should be fixed soon
- `MEDIUM` - Should be addressed
- `LOW` - Nice to have

### Adding More Resource Types

To check additional resource types, add them to the `resource_types` list in the definition section.

## Suppressing Checks

If you need to suppress a check for a specific resource, use inline comments:

```hcl
resource "aws_s3_bucket" "public_website" {
  #checkov:skip=CKV_AWS_CUSTOM_001:Public bucket required for static website hosting
  bucket = "my-public-website"
  acl    = "public-read"
  
  tags = {
    Environment = "prod"
    Owner       = "Marketing"
    Project     = "Website"
  }
}
```

## Integration with Terraform

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running Checkov security scan..."
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies --compact
if [ $? -ne 0 ]; then
    echo "Checkov scan failed. Please fix the issues before committing."
    exit 1
fi
```

### Terraform Plan Scanning

```bash
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
checkov -f tfplan.json --external-checks-dir tf.cert/checkov_policies
```

## Troubleshooting

### Policies Not Loading

1. Ensure YAML files are in the correct directory
2. Verify YAML syntax is valid: `yamllint tf.cert/checkov_policies/*.yaml`
3. Check file permissions are readable

### Verbose Output

Run Checkov with verbose logging to debug issues:
```bash
checkov -d tf.cert --external-checks-dir tf.cert/checkov_policies -v
```

### Common Issues

**Issue:** Policy not triggering  
**Solution:** Verify the `resource_types` in the YAML matches your Terraform resources exactly

**Issue:** False positives  
**Solution:** Adjust the `definition` conditions or use `#checkov:skip` comments

## Best Practices

1. **Run locally before pushing** - Use the provided `run_checks.sh` script
2. **Integrate in CI/CD** - Fail builds on CRITICAL violations
3. **Regular updates** - Review and update policies as requirements change
4. **Document exceptions** - Always add meaningful skip comments
5. **Test changes** - Use test samples to verify policy modifications

## Resources

- [Checkov Documentation](https://www.checkov.io/)
- [YAML-based Policies Guide](https://www.checkov.io/3.Custom%20Policies/YAML%20Custom%20Policies.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)

## Support

For issues or questions about these policies:
1. Review the policy YAML files for detailed descriptions
2. Check the examples in this README
3. Consult Checkov documentation
4. Review test samples in `test_samples/` directory

## License

These custom policies are provided as-is for use within your organization.