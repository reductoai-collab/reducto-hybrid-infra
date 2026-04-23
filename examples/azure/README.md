# Azure Blob Storage — Hybrid VPC Example

This example provisions Azure Blob Storage infrastructure for Reducto's Hybrid VPC deployment.

## What It Creates

- **Resource Group** — Container for all resources
- **Storage Account** — Standard LRS with TLS 1.2 minimum
- **Blob Container** — Private container for documents and artifacts
- **Lifecycle Policy** — Auto-deletes blobs after configurable retention period (default: 1 day)
- **RBAC Assignment** — Grants Reducto's service principal `Storage Blob Data Contributor` access

## Usage

1. Create `terraform.tfvars`:

```hcl
name_prefix       = "mycompany"
location          = "eastus"

# Provided by Reducto during onboarding
reducto_service_principal_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

tags = {
  Environment = "production"
}
```

2. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

3. Share the outputs with Reducto:

```bash
terraform output integration_values

# Connection string (sensitive — share securely)
terraform output -raw connection_string
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `name_prefix` | Prefix for resource names | (required) |
| `location` | Azure region | `eastus` |
| `resource_group_name` | Resource group name | `{prefix}-reducto-rg` |
| `reducto_service_principal_object_id` | Reducto's SP object ID | (required) |
| `lifecycle_expiration_days` | Blob auto-delete after N days | `1` |
| `tags` | Tags for all resources | `{}` |
