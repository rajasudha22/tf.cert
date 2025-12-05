# tf.cert - Terraform Security Compliance Framework

[![Checkov Security Scan](https://github.com/your-org/tf.cert/workflows/Checkov%20Security%20Scan/badge.svg)](https://github.com/your-org/tf.cert/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.0-blue)](https://www.terraform.io/)
[![Checkov](https://img.shields.io/badge/checkov-latest-purple)](https://www.checkov.io/)

A comprehensive Terraform security compliance framework with custom Checkov policies for AWS infrastructure. This repository demonstrates best practices for infrastructure-as-code security, automated compliance scanning, and policy enforcement.

## 📋 Table of Contents

- [Overview](#overview)
- [Why This Project?](#why-this-project)
- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Custom Security Policies](#custom-security-policies)
- [Infrastructure Components](#infrastructure-components)
- [Usage](#usage)
- [CI/CD Integration](#cicd-integration)
- [Compliance](#compliance)
- [Testing](#testing)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

## 🎯 Overview

**tf.cert** is a production-ready Terraform security compliance framework that enforces organizational security standards through custom Checkov policies. It provides automated security scanning, compliance validation, and policy enforcement for AWS infrastructure deployments.

### What This Repository Contains

- **Custom Checkov Policies**: 3 YAML-based security policies for AWS resources
- **Terraform Infrastructure**: Sample AWS infrastructure (VPC, EC2, S3, IAM)
- **Automated CI/CD**: GitHub Actions workflows for continuous security scanning
- **Compliance Documentation**: Detailed compliance reports and guidelines
- **Code Review Integration**: CodeRabbit configuration for automated reviews

## 🤔 Why This Project?

### The Problem

Organizations struggle with:
- **Inconsistent security controls** across cloud infrastructure
- **Manual compliance checks** that are time-consuming and error-prone
- **Lack of policy enforcement** in the development workflow
- **Security issues discovered too late** in the deployment cycle

### The Solution

This framework provides:
- ✅ **Automated security scanning** with custom policies
- ✅ **Policy-as-code** approach for consistent enforcement
- ✅ **Shift-left security** by catching issues during development
- ✅ **CI/CD integration** for continuous compliance validation
- ✅ **Clear compliance reporting** and audit trails

## ✨ Features

### Security Policies

- **🔒 S3 Bucket Public Access Prevention** (CRITICAL)
  - Prevents accidental public exposure of S3 buckets
  - Enforces public access block configuration
  
- **🔐 EC2 Instance Encryption** (HIGH)
  - Ensures all EC2 volumes are encrypted at rest
  - Validates root and additional EBS volumes
  
- **🏷️ Resource Default Tags** (MEDIUM)
  - Enforces required tags for governance and cost tracking
  - Validates env/Environment, Owner, project/Project, and cost-center tags

### Automation

- **GitHub Actions Workflows** for automated scanning on every push/PR
- **Multiple scan modes**: full scan, custom policies only, severity-based
- **PR comment integration** with detailed scan results
- **Artifact retention** for compliance audit trails

### Integration

- **CodeRabbit AI** for automated code reviews
- **Terraform validation** and linting
- **SARIF output** for security event integration
- **JSON reports** for downstream processing

## 🏗️ Architecture

```
tf.cert/
├── main.tf                      # IAM roles and EC2 instance configuration
├── s3.tf                        # S3 bucket with security controls
├── vpc.tf                       # VPC network infrastructure
├── provider.tf                  # AWS provider configuration
├── checkov.yaml                 # Checkov scanner configuration
├── COMPLIANCE.md                # Detailed compliance documentation
│
├── checkov_policies/            # Custom security policies
│   ├── S3BucketNoPublicAccess.yaml       # CKV_AWS_CUSTOM_001
│   ├── EC2InstanceEncryption.yaml        # CKV_AWS_CUSTOM_002
│   ├── ResourceDefaultTags.yaml          # CKV_AWS_CUSTOM_003
│   └── README.md                         # Policy documentation
│
└── .github/workflows/           # CI/CD automation
    └── checkov-scan.yaml        # Security scanning workflow
```

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
- Terraform >= 1.0
- Python >= 3.7
- Checkov (pip install checkov)
- AWS CLI (configured with credentials)
```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/tf.cert.git
   cd tf.cert
   ```

2. **Install Checkov**
   ```bash
   pip install checkov
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Run security scan**
   ```bash
   checkov -d . \
     --external-checks-dir ./checkov_policies \
     --framework terraform
   ```

### Basic Usage

```bash
# Validate Terraform configuration
terraform validate

# Run Checkov with custom policies
checkov -d . --external-checks-dir ./checkov_policies

# Plan infrastructure changes
terraform plan

# Apply changes (after passing security scans)
terraform apply
```

## 🛡️ Custom Security Policies

### 1. S3 Bucket Public Access Prevention (`CKV_AWS_CUSTOM_001`)

**Severity:** 🔴 CRITICAL

Prevents S3 buckets from being publicly accessible.

**Compliant Example:**
```hcl
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket-unique-name"
  
  tags = {
    Name        = "Application Bucket"
    env         = "production"
    Owner       = "DevOps Team"
    project     = "WebApp"
    cost-center = "12345"
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 2. EC2 Instance Encryption (`CKV_AWS_CUSTOM_002`)

**Severity:** 🟠 HIGH

Ensures all EC2 instances have encrypted EBS volumes.

**Compliant Example:**
```hcl
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 20
  }
  
  tags = {
    Name        = "AppServer"
    env         = "production"
    Owner       = "Platform Team"
    project     = "WebApp"
    cost-center = "67890"
  }
}
```

### 3. Resource Default Tags (`CKV_AWS_CUSTOM_003`)

**Severity:** 🟡 MEDIUM

Enforces required tags on all AWS resources for governance and cost tracking.

**Required Tags:**
- `env` or `Environment`: Environment name (dev, staging, production)
- `Owner`: Team or individual responsible
- `project` or `Project`: Project or application name
- `cost-center`: Cost center code for billing and chargeback purposes

**Applies to:** VPC, Subnet, EC2, S3, Security Groups, IAM Roles, Lambda, ECS, RDS, DynamoDB, and more.

[📚 Full policy documentation →](checkov_policies/README.md)

## 🏢 Infrastructure Components

### Network Infrastructure ([`vpc.tf`](vpc.tf))
- **VPC**: 10.0.0.0/16 with DNS support
- **Public Subnet**: 10.0.1.0/24 in us-east-1a
- **Internet Gateway**: For public internet access
- **Route Tables**: Configured for public routing

### Storage ([`s3.tf`](s3.tf))
- **S3 Bucket**: Application data storage
- **Public Access Block**: All public access disabled
- **Encryption**: Server-side encryption enabled
- **Versioning**: Configured for data protection

### Compute & IAM ([`main.tf`](main.tf))
- **IAM Role**: EC2 instance role with S3 access
- **Instance Profile**: For EC2 IAM permissions
- **Security Group**: SSH access control
- **EC2 Instance**: Amazon Linux 2 with encrypted volumes

All resources include required tags for compliance.

## 📖 Usage

### Local Development

```bash
# Run security scan before committing
checkov -d . --external-checks-dir ./checkov_policies --compact

# Check specific policy
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --check CKV_AWS_CUSTOM_001

# Generate JSON report
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --output json \
  --output-file-path console,scan-results.json

# Skip specific checks if needed
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --skip-check CKV_AWS_CUSTOM_003
```

### Terraform Workflow

```bash
# 1. Initialize
terraform init

# 2. Validate syntax
terraform validate

# 3. Format code
terraform fmt -recursive

# 4. Run security scan
checkov -d . --external-checks-dir ./checkov_policies

# 5. Plan changes
terraform plan -out=tfplan

# 6. Apply (if scan passes)
terraform apply tfplan
```

### Suppressing Checks

For legitimate exceptions, use inline comments:

```hcl
resource "aws_s3_bucket" "public_website" {
  #checkov:skip=CKV_AWS_CUSTOM_001:Public bucket required for static website
  bucket = "my-public-website"
  acl    = "public-read"
  
  tags = {
    env         = "production"
    Owner       = "Marketing"
    project     = "Website"
    cost-center = "98765"
  }
}
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow

The repository includes a comprehensive GitHub Actions workflow ([`.github/workflows/checkov-scan.yaml`](.github/workflows/checkov-scan.yaml)) that:

1. **Runs on every push and PR** to main/develop branches
2. **Executes three parallel scan jobs**:
   - Full Checkov scan with all policies
   - Custom policies only scan
   - Critical and High severity checks
3. **Posts results as PR comments** with detailed statistics
4. **Uploads scan artifacts** for compliance auditing
5. **Blocks merges** if custom policy violations are found

### Workflow Features

- ✅ Automatic security scanning on code changes
- ✅ PR comment integration with scan results
- ✅ Artifact retention for 30 days
- ✅ Fail-fast on critical violations
- ✅ Support for manual workflow dispatch

### Integration Example

```yaml
# Minimal GitHub Actions integration
- name: Run Checkov
  run: |
    pip install checkov
    checkov -d . \
      --external-checks-dir ./checkov_policies \
      --framework terraform \
      --compact
```

## 📊 Compliance

### Compliance Status

All infrastructure code in this repository is **fully compliant** with custom security policies.

✅ **CKV_AWS_CUSTOM_001**: S3 buckets have no public access  
✅ **CKV_AWS_CUSTOM_002**: EC2 instances have encrypted volumes  
✅ **CKV_AWS_CUSTOM_003**: All resources have required tags

[📄 Full compliance report →](COMPLIANCE.md)

### Compliance Validation

```bash
# Run full compliance check
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --framework terraform

# Expected output:
# Passed checks: XX
# Failed checks: 0
# Skipped checks: YY
```

### Audit Trail

- Scan results stored as GitHub Actions artifacts
- JSON reports for compliance reporting
- Git history for policy changes
- PR comments for audit records

## 🧪 Testing

### Test Files

Test your policies against sample configurations:

```bash
# Test against violations (should fail)
checkov -f test_samples/violations.tf \
  --external-checks-dir ./checkov_policies

# Test against compliant code (should pass)
checkov -f test_samples/compliant.tf \
  --external-checks-dir ./checkov_policies
```

### Creating Test Cases

```hcl
# test_samples/my_test.tf
# Test case for policy validation

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket"
  
  tags = {
    env         = "development"
    Owner       = "DevOps"
    project     = "Testing"
    cost-center = "11111"
  }
}
```

### Terraform Plan Scanning

Scan Terraform plans before applying:

```bash
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
checkov -f tfplan.json \
  --framework terraform_plan \
  --external-checks-dir ./checkov_policies
```

## 🤝 Contributing

### Adding New Policies

1. Create a new YAML file in [`checkov_policies/`](checkov_policies/)
2. Follow the naming convention: `ResourceTypePolicyName.yaml`
3. Define the policy with appropriate severity
4. Add documentation to [`checkov_policies/README.md`](checkov_policies/README.md)
5. Create test cases in `test_samples/`
6. Submit a PR with policy validation results

### Policy Template

```yaml
metadata:
  name: "Your Policy Name"
  id: "CKV_AWS_CUSTOM_XXX"
  category: "SECURITY"
  severity: "HIGH"

definition:
  cond_type: "attribute"
  resource_types:
    - "aws_resource_type"
  attribute: "resource.property"
  operator: "equals"
  value: "expected_value"
```

## 🔧 Troubleshooting

### Common Issues

**Problem**: Checkov not finding custom policies

```bash
# Solution: Verify external checks directory
ls -la checkov_policies/
checkov --external-checks-dir ./checkov_policies -v
```

**Problem**: False positive violations

```bash
# Solution: Use skip comments or adjust policy
#checkov:skip=CKV_AWS_CUSTOM_XXX:Explanation here
```

**Problem**: GitHub Actions failing

```bash
# Solution: Check workflow logs and verify:
# 1. Checkov installation succeeded
# 2. Custom policies are in repository
# 3. Terraform files are valid
```

### Debug Mode

```bash
# Run Checkov in verbose mode
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --framework terraform \
  -v
```

## 📚 Resources

### Documentation

- [Checkov Documentation](https://www.checkov.io/)
- [Custom YAML Policies Guide](https://www.checkov.io/3.Custom%20Policies/YAML%20Custom%20Policies.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)

### Related Files

- [📋 Custom Policies Documentation](checkov_policies/README.md)
- [📊 Compliance Report](COMPLIANCE.md)
- [🔄 GitHub Actions Workflow](.github/workflows/checkov-scan.yaml)
- [⚙️ Checkov Configuration](checkov.yaml)
- [🤖 CodeRabbit Configuration](.coderabbit.yaml)

### Support

For questions or issues:
1. Check the [troubleshooting section](#troubleshooting)
2. Review [policy documentation](checkov_policies/README.md)
3. Consult [compliance guide](COMPLIANCE.md)
4. Open an issue with detailed logs

## 📝 License

This project is provided as-is for organizational use. Modify and extend as needed for your security requirements.

## 🎯 Next Steps

1. **Customize policies** for your organization's needs
2. **Integrate with your CI/CD** pipeline
3. **Add more custom policies** for additional AWS services
4. **Set up policy exceptions** using skip comments
5. **Monitor compliance** through regular scans

---

**Built with ❤️ for Infrastructure Security**

*Ensuring secure, compliant, and well-governed AWS infrastructure through automated policy enforcement.*
