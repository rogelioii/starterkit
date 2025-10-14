#!/bin/bash

# Terraform State Management Initialization Script
# This script helps initialize Terraform with either local or remote (S3/DynamoDB) state management

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local                    Initialize with local state management"
    echo "  --remote                   Initialize with remote state management (S3/DynamoDB)"
    echo "  --bucket BUCKET_NAME       S3 bucket name for remote state (required with --remote)"
    echo "  --region REGION           AWS region (default: us-east-1)"
    echo "  --dynamo-table TABLE      DynamoDB table name for state locking (optional)"
    echo "  --key KEY_PATH            State file key path in S3 (default: terraform.tfstate)"
    echo "  --profile PROFILE         AWS profile to use (optional)"
    echo "  --workspace WORKSPACE     Create and select a specific workspace (optional)"
    echo "  --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --local"
    echo "  $0 --remote --bucket my-terraform-state --region us-west-2"
    echo "  $0 --remote --bucket my-terraform-state --dynamo-table terraform-locks --key prod/terraform.tfstate"
    echo "  $0 --remote --bucket my-terraform-state --workspace dev"
    echo "  $0 --local --workspace staging"
}

# Function to check if required tools are installed
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_warning "AWS CLI is not installed. Required for remote state management."
    fi
    
    print_success "Dependencies check completed"
}

# Function to initialize local state
init_local_state() {
    local workspace=$1
    
    print_info "Initializing Terraform with local state management..."
    
    # Check if terraform is already initialized
    if [ -d ".terraform" ]; then
        print_warning "Terraform is already initialized. Reinitializing..."
        terraform init -reconfigure
    else
        terraform init
    fi
    
    # Handle workspace if specified
    if [ -n "$workspace" ]; then
        handle_workspace "$workspace"
    fi
    
    print_success "Local state management initialized successfully"
    if [ -n "$workspace" ]; then
        print_info "State will be stored locally in terraform.tfstate.d/$workspace/terraform.tfstate"
    else
        print_info "State will be stored locally in terraform.tfstate"
    fi
}

# Function to create S3 bucket if it doesn't exist
create_s3_bucket() {
    local bucket_name=$1
    local region=$2
    local profile=$3
    
    print_info "Checking if S3 bucket '$bucket_name' exists..."
    
    local aws_cmd="aws s3api head-bucket --bucket $bucket_name"
    if [ -n "$profile" ]; then
        aws_cmd="$aws_cmd --profile $profile"
    fi
    
    if $aws_cmd 2>/dev/null; then
        print_success "S3 bucket '$bucket_name' already exists"
    else
        print_info "Creating S3 bucket '$bucket_name' in region '$region'..."
        
        local create_cmd="aws s3api create-bucket --bucket $bucket_name --region $region"
        if [ -n "$profile" ]; then
            create_cmd="$create_cmd --profile $profile"
        fi
        
        # For us-east-1, don't specify location constraint
        if [ "$region" != "us-east-1" ]; then
            create_cmd="$create_cmd --create-bucket-configuration LocationConstraint=$region"
        fi
        
        if $create_cmd; then
            print_success "S3 bucket '$bucket_name' created successfully"
            
            # Enable versioning
            print_info "Enabling versioning on S3 bucket..."
            local version_cmd="aws s3api put-bucket-versioning --bucket $bucket_name --versioning-configuration Status=Enabled"
            if [ -n "$profile" ]; then
                version_cmd="$version_cmd --profile $profile"
            fi
            $version_cmd
            
            # Enable server-side encryption
            print_info "Enabling server-side encryption on S3 bucket..."
            local encrypt_cmd="aws s3api put-bucket-encryption --bucket $bucket_name --server-side-encryption-configuration '{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}'"
            if [ -n "$profile" ]; then
                encrypt_cmd="$encrypt_cmd --profile $profile"
            fi
            $encrypt_cmd
            
        else
            print_error "Failed to create S3 bucket '$bucket_name'"
            exit 1
        fi
    fi
}

# Function to create DynamoDB table if it doesn't exist
create_dynamo_table() {
    local table_name=$1
    local region=$2
    local profile=$3
    
    print_info "Checking if DynamoDB table '$table_name' exists..."
    
    local aws_cmd="aws dynamodb describe-table --table-name $table_name"
    if [ -n "$profile" ]; then
        aws_cmd="$aws_cmd --profile $profile"
    fi
    
    if $aws_cmd 2>/dev/null; then
        print_success "DynamoDB table '$table_name' already exists"
    else
        print_info "Creating DynamoDB table '$table_name'..."
        
        local create_cmd="aws dynamodb create-table --table-name $table_name --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST"
        if [ -n "$profile" ]; then
            create_cmd="$create_cmd --profile $profile"
        fi
        
        if $create_cmd; then
            print_success "DynamoDB table '$table_name' created successfully"
            print_info "Waiting for table to become active..."
            aws dynamodb wait table-exists --table-name $table_name
        else
            print_error "Failed to create DynamoDB table '$table_name'"
            exit 1
        fi
    fi
}

# Function to handle workspace creation and selection
handle_workspace() {
    local workspace=$1
    
    print_info "Managing workspace: $workspace"
    
    # Check if workspace exists
    if terraform workspace list | grep -q "^\s*$workspace\s*$"; then
        print_info "Workspace '$workspace' already exists. Selecting it..."
        terraform workspace select "$workspace"
    else
        print_info "Creating new workspace: $workspace"
        terraform workspace new "$workspace"
    fi
    
    print_success "Now using workspace: $workspace"
}

# Function to initialize remote state
init_remote_state() {
    local bucket_name=$1
    local region=$2
    local dynamo_table=$3
    local key_path=$4
    local profile=$5
    local workspace=$6
    
    print_info "Initializing Terraform with remote state management..."
    
    # Create S3 bucket
    create_s3_bucket "$bucket_name" "$region" "$profile"
    
    # Create DynamoDB table if specified
    if [ -n "$dynamo_table" ]; then
        create_dynamo_table "$dynamo_table" "$region" "$profile"
    fi
    
    # Create backend configuration
    print_info "Creating backend configuration..."
    
    cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$bucket_name"
    key            = "$key_path"
    region         = "$region"
EOF

    if [ -n "$dynamo_table" ]; then
        cat >> backend.tf << EOF
    dynamodb_table = "$dynamo_table"
EOF
    fi

    if [ -n "$profile" ]; then
        cat >> backend.tf << EOF
    profile        = "$profile"
EOF
    fi

    cat >> backend.tf << EOF
    encrypt        = true
  }
}
EOF
    
    print_success "Backend configuration created in backend.tf"
    
    # Initialize Terraform
    if [ -d ".terraform" ]; then
        print_warning "Terraform is already initialized. Reinitializing with new backend..."
        terraform init -reconfigure
    else
        terraform init
    fi
    
    # Handle workspace if specified
    if [ -n "$workspace" ]; then
        handle_workspace "$workspace"
    fi
    
    print_success "Remote state management initialized successfully"
    print_info "State will be stored in S3 bucket: $bucket_name"
    if [ -n "$workspace" ]; then
        print_info "State file key: env:$workspace/$key_path"
    else
        print_info "State file key: $key_path"
    fi
    if [ -n "$dynamo_table" ]; then
        print_info "State locking enabled with DynamoDB table: $dynamo_table"
    fi
}

# Main script logic
main() {
    local backend_type=""
    local bucket_name=""
    local region="us-east-1"
    local dynamo_table=""
    local key_path="terraform.tfstate"
    local profile=""
    local workspace=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --local)
                backend_type="local"
                shift
                ;;
            --remote)
                backend_type="remote"
                shift
                ;;
            --bucket)
                bucket_name="$2"
                shift 2
                ;;
            --region)
                region="$2"
                shift 2
                ;;
            --dynamo-table)
                dynamo_table="$2"
                shift 2
                ;;
            --key)
                key_path="$2"
                shift 2
                ;;
            --profile)
                profile="$2"
                shift 2
                ;;
            --workspace)
                workspace="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [ -z "$backend_type" ]; then
        print_error "Please specify either --local or --remote backend type"
        show_usage
        exit 1
    fi
    
    if [ "$backend_type" = "remote" ] && [ -z "$bucket_name" ]; then
        print_error "S3 bucket name is required when using remote backend. Use --bucket option."
        show_usage
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Initialize based on backend type
    if [ "$backend_type" = "local" ]; then
        init_local_state "$workspace"
    elif [ "$backend_type" = "remote" ]; then
        init_remote_state "$bucket_name" "$region" "$dynamo_table" "$key_path" "$profile" "$workspace"
    fi
    
    print_success "Terraform state management initialization completed!"
}

# Run main function with all arguments
main "$@"
