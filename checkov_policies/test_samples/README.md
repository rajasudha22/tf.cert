# Checkov Custom Policies - Test Samples

This directory contains test samples for validating the custom Checkov policies.

## Files

- **[`violations.tf`](violations.tf)** - Contains intentional policy violations for testing
- **[`compliant.tf`](compliant.tf)** - Contains compliant configurations that should pass all checks

## Usage

### Test Policy Violations

Run Checkov against the violations file to verify policies detect issues:

```bash
# From the project root
checkov -f tf.cert/checkov_policies/test_samples/violations.tf \
  --external-checks-dir tf.cert/checkov_policies

# Expected: Multiple failures across all three policies
```

**Expected Results:**
- ❌ 3 failures for `CKV_AWS_CUSTOM_001` (S3 public access)
- ❌ 4 failures for `CKV_AWS_CUSTOM_002` (EC2 encryption)
- ❌ 7 failures for `CKV_AWS_CUSTOM_003` (Required tags)

### Test Compliant Configurations

Run Checkov against the compliant file to verify policies pass valid configurations:

```bash
# From the project root
checkov -f tf.cert/checkov_policies/test_samples/compliant.tf \
  --external-checks-dir tf.cert/checkov_policies

# Expected: All checks should pass
```

**Expected Results:**
- ✅ All resources should pass policy checks
- No failures for custom policies

### Run Both Tests

Test both files together:

```bash
# Test violations
echo "Testing violations..."
checkov -f tf.cert/checkov_policies/test_samples/violations.tf \
  --external-checks-dir tf.cert/checkov_policies \
  --compact

# Test compliant configurations
echo -e "\nTesting compliant configurations..."
checkov -f tf.cert/checkov_policies/test_samples/compliant.tf \
  --external-checks-dir tf.cert/checkov_policies \
  --compact
```

## Test Coverage

### CKV_AWS_CUSTOM_001: S3 Bucket Public Access Prevention

**Violations tested:**
- S3 bucket with `public-read` ACL
- S3 bucket with `public-read-write` ACL
- S3 bucket with `authenticated-read` ACL

**Compliant cases tested:**
- S3 bucket with no ACL (defaults to private)
- S3 bucket with explicit `private` ACL
- S3 bucket with public access block configuration

### CKV_AWS_CUSTOM_002: EC2 Instance Encryption

**Violations tested:**
- EC2 instance without any encryption configuration
- EC2 instance with explicitly disabled encryption
- EC2 instance with partial encryption (root encrypted, EBS not)

**Compliant cases tested:**
- EC2 instance with encrypted root volume
- EC2 instance with encrypted root and multiple EBS volumes
- EC2 instance using KMS keys for encryption

### CKV_AWS_CUSTOM_003: Resource Default Tags

**Violations tested:**
- Resources with no tags
- Resources with incomplete tags (missing required tags)
- Multiple resource types: EC2, S3, VPC, Lambda

**Compliant cases tested:**
- Resources with all required tags (Environment, Owner, Project)
- Multiple resource types properly tagged
- Resources with additional optional tags

## Adding New Tests

To add new test cases:

1. Add violation examples to [`violations.tf`](violations.tf)
2. Add compliant examples to [`compliant.tf`](compliant.tf)
3. Run the tests to verify
4. Update this README with new test coverage

## Automated Testing

You can create a simple test script:

```bash
#!/bin/bash
# test_policies.sh

set -e

echo "=== Testing Checkov Custom Policies ==="
echo ""

# Test violations - expect failures
echo "1. Testing policy violations (should fail)..."
if checkov -f tf.cert/checkov_policies/test_samples/violations.tf \
    --external-checks-dir tf.cert/checkov_policies \
    --quiet --compact; then
    echo "❌ ERROR: Violations test should have failed but passed!"
    exit 1
else
    echo "✓ Violations correctly detected"
fi

echo ""

# Test compliant - expect pass
echo "2. Testing compliant configurations (should pass)..."
if checkov -f tf.cert/checkov_policies/test_samples/compliant.tf \
    --external-checks-dir tf.cert/checkov_policies \
    --compact; then
    echo "✓ Compliant configurations passed"
else
    echo "❌ ERROR: Compliant configurations failed!"
    exit 1
fi

echo ""
echo "=== All tests completed successfully ==="
```

Save this as `test_policies.sh` and run:
```bash
chmod +x test_policies.sh
./test_policies.sh