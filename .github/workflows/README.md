# GitHub Actions Workflows for Checkov

This directory contains GitHub Actions workflows for running Checkov security scans with custom policies on Terraform code.

## Available Workflows

### 1. Checkov Security Scan (Advanced) - [`checkov-scan.yaml`](checkov-scan.yaml)

**Features:**
- Comprehensive security scanning with custom policies
- Multiple jobs for different scan types
- PR comments with scan results
- Artifact uploads for detailed results
- Severity-based scanning
- Terraform plan scanning

**Jobs:**
- `checkov-scan` - Main security scan with all policies
- `checkov-custom-policies-only` - Run only custom policies
- `checkov-by-severity` - Run critical and high severity checks
- `terraform-plan-scan` - Scan Terraform execution plans

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch
- Only when `.tf` files or policies change

**Usage:**
This workflow will automatically run when you push code or create a PR. No additional setup required.

### 2. Checkov Simple Scan - [`checkov-simple.yaml`](checkov-simple.yaml)

**Features:**
- Lightweight, fast security scanning
- Minimal configuration
- Ideal for quick validation
- Fails build on any policy violation

**Jobs:**
- `security-scan` - Single job that runs all custom policies

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`

**Usage:**
Perfect for teams getting started with Checkov or who want a simple, straightforward scan.

## Setup Instructions

### Quick Start

1. **Copy workflows to your repository:**
   ```bash
   # If not already in .github/workflows/
   mkdir -p .github/workflows
   cp tf.cert/.github/workflows/checkov-*.yaml .github/workflows/
   ```

2. **Ensure custom policies are in the repository:**
   ```bash
   # Policies should be in: tf.cert/checkov_policies/
   ls tf.cert/checkov_policies/*.yaml
   ```

3. **Commit and push:**
   ```bash
   git add .github/workflows/
   git commit -m "Add Checkov security scanning workflows"
   git push
   ```

4. **Workflow will run automatically** on the next push or PR.

### Choosing a Workflow

**Use `checkov-simple.yaml` if:**
- ✅ You want quick setup
- ✅ You need basic security scanning
- ✅ You want to fail builds on violations
- ✅ You don't need detailed reporting

**Use `checkov-scan.yaml` if:**
- ✅ You need comprehensive scanning
- ✅ You want PR comments with results
- ✅ You need artifact uploads
- ✅ You want severity-based scanning
- ✅ You scan Terraform plans

### Permissions Required

For the advanced workflow, ensure your GitHub Actions has these permissions in repository settings:

```yaml
permissions:
  contents: read          # Read repository code
  security-events: write  # Upload security results
  pull-requests: write    # Comment on PRs
```

Or add to your repository settings:
- Go to **Settings** → **Actions** → **General**
- Under **Workflow permissions**, select "Read and write permissions"

## Workflow Configuration

### Environment Variables

You can customize behavior with environment variables in the workflow:

```yaml
env:
  CHECKOV_VERSION: "latest"  # Or pin to specific version like "2.5.0"
  PYTHON_VERSION: "3.11"
  TF_VERSION: "1.6.0"
```

### Path Filters

Workflows only run when relevant files change:

```yaml
paths:
  - '**.tf'                # All Terraform files
  - 'checkov_policies/**' # Custom policies
```

### Custom Policy Selection

Run specific policies only:

```yaml
- name: Run specific policies
  run: |
    checkov -d . \
      --external-checks-dir ./checkov_policies \
      --check CKV_AWS_CUSTOM_001,CKV_AWS_CUSTOM_002 \
      --framework terraform
```

### Soft Fail Mode

Allow workflow to pass even with violations (for gradual rollout):

```yaml
- name: Run Checkov (soft fail)
  run: |
    checkov -d . \
      --external-checks-dir ./checkov_policies \
      --framework terraform \
      --soft-fail
```

## Viewing Results

### In GitHub Actions

1. Go to **Actions** tab in your repository
2. Select the workflow run
3. View job logs for detailed output
4. Check **Artifacts** section for downloadable results

### PR Comments

The advanced workflow posts scan results as PR comments:

```
## 🔍 Checkov Security Scan Results

| Status | Count |
|--------|-------|
| ✅ Passed | 45 |
| ❌ Failed | 3 |
| ⏭️ Skipped | 2 |
| 🎯 Custom Policy Failures | 2 |
```

### Artifacts

Download detailed results:
- JSON format results
- CLI output
- Terraform plan analysis

Artifacts are retained for 30 days (configurable).

## Troubleshooting

### Workflow Fails Immediately

**Issue:** Workflow fails in setup step

**Solution:** Check Python/Checkov installation:
```yaml
- name: Debug installation
  run: |
    python --version
    pip list | grep checkov
```

### Custom Policies Not Found

**Issue:** Error: "External checks directory not found"

**Solution:** Verify path in workflow matches your repository structure:
```yaml
--external-checks-dir ./tf.cert/checkov_policies  # Adjust path as needed
```

### No PR Comments Posted

**Issue:** PR comments not appearing

**Solution:** 
1. Check workflow permissions (see Permissions section)
2. Ensure workflow runs on `pull_request` event
3. Verify `GITHUB_TOKEN` has write access

### False Positives

**Issue:** Legitimate code failing checks

**Solution:** Use skip comments in Terraform:
```hcl
resource "aws_s3_bucket" "public_website" {
  #checkov:skip=CKV_AWS_CUSTOM_001:Public bucket required for static website
  bucket = "my-public-website"
  acl    = "public-read"
}
```

## Advanced Configurations

### Run on Specific Paths Only

```yaml
on:
  push:
    paths:
      - 'terraform/prod/**'
      - 'terraform/staging/**'
```

### Matrix Strategy for Multiple Environments

```yaml
jobs:
  scan:
    strategy:
      matrix:
        environment: [dev, staging, prod]
    steps:
      - name: Scan ${{ matrix.environment }}
        run: checkov -d terraform/${{ matrix.environment }}
```

### Integration with Terraform Plan

```yaml
- name: Generate and scan plan
  run: |
    terraform init
    terraform plan -out=tfplan.binary
    terraform show -json tfplan.binary > tfplan.json
    checkov -f tfplan.json --framework terraform_plan
```

### Send Notifications

```yaml
- name: Notify on failure
  if: failure()
  uses: actions/slack@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    message: "Checkov scan failed! Check the workflow run."
```

## Policy Enforcement Strategies

### Blocking Strategy (Strict)

Fail builds on any violation:
```yaml
continue-on-error: false  # Build fails on violations
```

### Warning Strategy (Gradual Rollout)

Report violations but don't fail:
```yaml
continue-on-error: true   # Build passes, violations logged
```

### Severity-Based Strategy

Fail only on critical/high:
```yaml
- name: Check critical issues
  run: checkov -d . --check CKV_AWS_CUSTOM_001
  continue-on-error: false

- name: Check medium issues  
  run: checkov -d . --check CKV_AWS_CUSTOM_003
  continue-on-error: true   # Don't fail on medium severity
```

## Best Practices

1. **Start with soft-fail** to assess current state
2. **Enable PR comments** for visibility
3. **Use artifacts** for detailed investigation
4. **Run on PR and push** for comprehensive coverage
5. **Pin Checkov version** for consistency
6. **Test locally first** using the same command
7. **Document skip reasons** when bypassing checks
8. **Review results regularly** and update policies

## Local Testing

Test the same checks locally before pushing:

```bash
# Install Checkov
pip install checkov

# Run the same scan as CI
checkov -d . \
  --external-checks-dir ./checkov_policies \
  --framework terraform \
  --compact
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Checkov Documentation](https://www.checkov.io/)
- [Checkov GitHub Actions](https://github.com/bridgecrewio/checkov-action)
- [Custom Policies README](../checkov_policies/README.md)

## Support

For issues with workflows:
1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Test locally using the same commands
4. Consult Checkov documentation