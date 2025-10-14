# Terraform State Management

This directory contains tools and scripts for managing Terraform state, including initialization scripts for both local and remote state management using AWS S3 and DynamoDB.

## Overview

Terraform state management is crucial for maintaining infrastructure consistency and enabling team collaboration. This repository provides automated scripts to set up Terraform state management with two main options:

- **Local State**: State stored locally in `terraform.tfstate` files
- **Remote State**: State stored in AWS S3 with optional DynamoDB locking

## Prerequisites

Before using these scripts, ensure you have the following tools installed:

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) - Infrastructure as Code tool
- [AWS CLI](https://aws.amazon.com/cli/) - For remote state management

### AWS Permissions (for remote state)
If using remote state management, ensure your AWS credentials have the following permissions:

**S3 Permissions:**
- `s3:CreateBucket`
- `s3:DeleteBucket`
- `s3:GetBucketLocation`
- `s3:GetBucketVersioning`
- `s3:PutBucketVersioning`
- `s3:GetBucketEncryption`
- `s3:PutBucketEncryption`
- `s3:GetObject`
- `s3:PutObject`
- `s3:DeleteObject`

**DynamoDB Permissions (if using state locking):**
- `dynamodb:CreateTable`
- `dynamodb:DescribeTable`
- `dynamodb:GetItem`
- `dynamodb:PutItem`
- `dynamodb:DeleteItem`

## Scripts

### `init-terraform-state.sh`

A comprehensive bash script that initializes Terraform state management with support for both local and remote backends.

#### Features

- **Local State Management**: Initialize Terraform with local state storage
- **Remote State Management**: Initialize Terraform with S3 backend and optional DynamoDB locking
- **Automatic Resource Creation**: Creates S3 buckets and DynamoDB tables as needed
- **Security Best Practices**: Enables versioning and encryption on S3 buckets
- **Error Handling**: Comprehensive error checking and validation
- **Colored Output**: Clear, colored terminal output for better user experience

#### Usage

```bash
# Make the script executable
chmod +x init-terraform-state.sh

# Show help
./init-terraform-state.sh --help
```

#### Command Line Options

| Option | Description | Required | Default |
|--------|-------------|----------|---------|
| `--local` | Initialize with local state management | No* | - |
| `--remote` | Initialize with remote state management | No* | - |
| `--bucket BUCKET_NAME` | S3 bucket name for remote state | Yes (with --remote) | - |
| `--region REGION` | AWS region | No | us-east-1 |
| `--dynamo-table TABLE` | DynamoDB table name for state locking | No | - |
| `--key KEY_PATH` | State file key path in S3 | No | terraform.tfstate |
| `--profile PROFILE` | AWS profile to use | No | - |
| `--workspace WORKSPACE` | Create and select a specific workspace | No | - |
| `--help` | Show help message | No | - |

*Either `--local` or `--remote` is required.

#### Examples

**Local State Management:**
```bash
./init-terraform-state.sh --local
```

**Remote State Management (Basic):**
```bash
./init-terraform-state.sh --remote --bucket my-terraform-state-bucket
```

**Remote State Management (Full Configuration):**
```bash
./init-terraform-state.sh \
  --remote \
  --bucket my-terraform-state-bucket \
  --region us-west-2 \
  --dynamo-table terraform-state-locks \
  --key production/terraform.tfstate \
  --profile production
```

**With Workspaces:**
```bash
# Initialize with a specific workspace
./init-terraform-state.sh --remote --bucket my-terraform-state --workspace dev
./init-terraform-state.sh --local --workspace staging
```

**Multiple Environments:**
```bash
# Development environment
./init-terraform-state.sh --remote --bucket my-terraform-state --key dev/terraform.tfstate

# Staging environment
./init-terraform-state.sh --remote --bucket my-terraform-state --key staging/terraform.tfstate

# Production environment
./init-terraform-state.sh --remote --bucket my-terraform-state --key prod/terraform.tfstate
```

## Terraform Workspaces Support

The script is fully compatible with Terraform workspaces and includes enhanced workspace management features:

### Workspace Features
- **Automatic Workspace Creation**: Use `--workspace` flag to create and select a workspace during initialization
- **State Isolation**: Each workspace maintains its own isolated state file
- **Backend Compatibility**: Works with both local and remote (S3/DynamoDB) backends

### How Workspaces Work

**Local State with Workspaces:**
- Default workspace: `terraform.tfstate`
- Named workspaces: `terraform.tfstate.d/<workspace_name>/terraform.tfstate`

**Remote State with Workspaces:**
- Default workspace: `s3://bucket/key/terraform.tfstate`
- Named workspaces: `s3://bucket/key/env:<workspace_name>/terraform.tfstate`

### Workspace Management Commands

After initialization, you can manage workspaces using standard Terraform commands:

```bash
# List all workspaces
terraform workspace list

# Create a new workspace
terraform workspace new <workspace_name>

# Switch to a workspace
terraform workspace select <workspace_name>

# Show current workspace
terraform workspace show

# Delete a workspace (be careful!)
terraform workspace delete <workspace_name>
```

## State Management Strategies

### Local State Management

**When to use:**
- Personal projects or learning
- Single-developer environments
- Temporary or experimental infrastructure

**Pros:**
- Simple setup
- No additional AWS costs
- Fast access

**Cons:**
- Not suitable for team collaboration
- Risk of state loss
- No state locking

### Remote State Management

**When to use:**
- Team collaboration
- Production environments
- CI/CD pipelines
- Multiple environments

**Pros:**
- Team collaboration support
- State locking prevents conflicts
- State backup and versioning
- Secure and encrypted storage

**Cons:**
- Additional AWS costs
- Requires AWS permissions
- Slightly slower access

## Best Practices

### S3 Bucket Naming
- Use descriptive, unique names
- Include environment or project identifier
- Follow AWS naming conventions
- Example: `mycompany-terraform-state-prod`

### State File Organization
- Use hierarchical key paths for different environments
- Examples:
  - `dev/terraform.tfstate`
  - `staging/terraform.tfstate`
  - `prod/terraform.tfstate`
  - `infrastructure/networking/terraform.tfstate`

### DynamoDB Table Configuration
- Use descriptive table names
- Enable point-in-time recovery for production
- Consider using separate tables per environment
- Example: `terraform-state-locks-prod`

### Security Considerations
- Enable S3 bucket versioning
- Enable S3 bucket encryption
- Use IAM roles with minimal required permissions
- Consider using AWS KMS for encryption keys
- Enable DynamoDB point-in-time recovery

## Troubleshooting

### Common Issues

**AWS Credentials Not Found:**
```bash
# Configure AWS credentials
aws configure

# Or use a specific profile
export AWS_PROFILE=your-profile-name
```

**S3 Bucket Already Exists:**
- The script will detect existing buckets and continue
- Ensure you have appropriate permissions

**DynamoDB Table Creation Fails:**
- Check AWS permissions
- Ensure table name is unique in the region
- Verify DynamoDB service is available in the region

**Terraform Already Initialized:**
- The script will reinitialize with `terraform init -reconfigure`
- This is safe and will update the backend configuration

### Debugging

Enable verbose output by setting environment variables:
```bash
export TF_LOG=DEBUG
export AWS_CLI_AUTO_PROMPT=on-partial
```

## File Structure

After running the initialization script, your directory structure will look like this:

```
terraform/
├── init-terraform-state.sh    # Initialization script
├── README.md                  # This documentation
├── backend.tf                 # Generated backend configuration (remote only)
├── .terraform/                # Terraform working directory
│   └── terraform.tfstate      # Local state (local backend only)
└── terraform.tfstate          # Local state file (local backend only)
```

## VPC Configuration

This directory also includes a complete VPC configuration with Terraform that creates a standard AWS VPC setup.

### VPC Architecture

The VPC configuration creates:

- **VPC**: Custom CIDR block (default: 10.0.0.0/16)
- **3 Public Subnets**: One in each availability zone with Internet Gateway access
- **3 Private Subnets**: One in each availability zone with NAT Gateway access
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: Shared NAT Gateway for private subnet internet access
- **Route Tables**: Separate routing for public and private subnets
- **Optional Features**: VPN Gateway, VPC Flow Logs

### VPC Files

- `variables.tf` - Input variables for VPC configuration
- `vpc.tf` - Main VPC resources and configuration
- `outputs.tf` - Output values from VPC resources
- `terraform.tfvars.example` - Example variable values

### Quick Start with VPC

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Customize your variables in `terraform.tfvars`:**
   ```hcl
   project_name = "my-project"
   environment  = "dev"
   aws_region   = "us-east-1"
   ```

3. **Initialize Terraform with state management:**
   ```bash
   # For local development
   ./init-terraform-state.sh --local --workspace dev
   
   # For team collaboration
   ./init-terraform-state.sh --remote --bucket my-terraform-state --workspace dev
   ```

4. **Deploy the VPC:**
   ```bash
   terraform plan
   terraform apply
   ```

### VPC Configuration Options

#### Basic Configuration
- `project_name` - Used for resource naming
- `environment` - Environment identifier (dev, staging, prod)
- `vpc_cidr` - CIDR block for the VPC
- `availability_zones` - List of AZs to use

#### Subnet Configuration
- `public_subnet_cidrs` - CIDR blocks for public subnets
- `private_subnet_cidrs` - CIDR blocks for private subnets

#### NAT Gateway Options
- `enable_nat_gateway` - Enable/disable NAT Gateway
- `nat_gateway_type` - "single" (shared) or "multiple" (one per AZ)

#### Optional Features
- `enable_vpn_gateway` - Enable VPN Gateway
- `enable_flow_logs` - Enable VPC Flow Logs
- `flow_log_destination_type` - "cloud-watch-logs" or "s3"

### VPC Outputs

After deployment, you can access VPC information through outputs:

```bash
# Get VPC ID
terraform output vpc_id

# Get subnet IDs
terraform output public_subnet_ids
terraform output private_subnet_ids

# Get NAT Gateway information
terraform output nat_gateway_ids
terraform output nat_gateway_public_ips
```

### VPC Best Practices

1. **Use descriptive naming**: Include project and environment in resource names
2. **Separate environments**: Use different workspaces or state files for dev/staging/prod
3. **NAT Gateway strategy**: 
   - Single NAT Gateway for cost optimization
   - Multiple NAT Gateways for high availability
4. **Security**: Enable VPC Flow Logs for monitoring and compliance
5. **CIDR planning**: Ensure sufficient IP space for future growth

### Cost Considerations

- **Single NAT Gateway**: ~$45/month + data processing
- **Multiple NAT Gateways**: ~$135/month + data processing (3 AZs)
- **VPC Flow Logs**: Additional CloudWatch or S3 costs
- **VPN Gateway**: ~$36/month if enabled

## Contributing

When contributing to this repository:

1. Test the script with both local and remote backends
2. Ensure error handling covers edge cases
3. Update documentation for any new features
4. Follow bash scripting best practices
5. Test VPC configurations in different regions
6. Validate CIDR block calculations

## License

This project is part of the starterkit repository. Please refer to the main repository license for usage terms.
