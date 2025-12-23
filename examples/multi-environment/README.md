# Multi-Environment Setup

This example demonstrates how to set up Reducto Hybrid VPC infrastructure across multiple AWS accounts or environments (e.g., dev, staging, prod).

## Directory Structure

```
multi-environment/
├── dev/
│   ├── main.tf
│   ├── terraform.tfvars
│   └── backend.tf
├── staging/
│   ├── main.tf
│   ├── terraform.tfvars
│   └── backend.tf
└── prod/
    ├── main.tf
    ├── terraform.tfvars
    └── backend.tf
```

## Setup Instructions

1. **Create environment directories**: Copy the template files to each environment folder.

2. **Configure each environment**: Update `terraform.tfvars` with environment-specific values:
   - Different `name_prefix` per environment (e.g., `reducto-dev`, `reducto-prod`)
   - Environment-specific tags
   - Separate state files in `backend.tf`

3. **Run Terraform separately for each environment**:
   ```bash
   cd dev
   terraform init
   terraform apply

   cd ../staging
   terraform init
   terraform apply

   cd ../prod
   terraform init
   terraform apply
   ```

4. **Register each environment with Reducto**: Provide the `integration_values` output from each environment to your Reducto account team.

## Best Practices

- Use separate AWS accounts for each environment when possible
- Use separate Terraform state files (S3 backend with different keys)
- Apply consistent tagging across environments
- Consider using Terraform workspaces as an alternative approach
