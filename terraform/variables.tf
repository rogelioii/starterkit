# VPC Configuration Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# NAT Gateway Configuration
variable "nat_gateway_type" {
  description = "NAT Gateway type (single or multiple)"
  type        = string
  default     = "single"
  validation {
    condition     = contains(["single", "multiple"], var.nat_gateway_type)
    error_message = "NAT Gateway type must be either 'single' or 'multiple'."
  }
}

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_destination_type" {
  description = "Type of destination for VPC Flow Logs (cloud-watch-logs, s3)"
  type        = string
  default     = "cloud-watch-logs"
  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_log_destination_type)
    error_message = "Flow log destination type must be either 'cloud-watch-logs' or 's3'."
  }
}

variable "flow_log_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  type        = string
  default     = ""
}

variable "flow_log_s3_bucket_name" {
  description = "S3 bucket name for VPC Flow Logs"
  type        = string
  default     = ""
}

# EC2 Configuration Variables
variable "enable_ec2_instances" {
  description = "Enable EC2 instances creation"
  type        = bool
  default     = true
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "ec2_key_name" {
  description = "Name of the EC2 Key Pair to use for instances"
  type        = string
  default     = ""
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "ec2_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "ec2_root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.ec2_root_volume_type)
    error_message = "Root volume type must be one of: gp2, gp3, io1, io2, st1, sc1."
  }
}

variable "ec2_root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  type        = bool
  default     = true
}

variable "enable_public_ec2" {
  description = "Enable public EC2 instance"
  type        = bool
  default     = true
}

variable "enable_private_ec2" {
  description = "Enable private EC2 instance"
  type        = bool
  default     = true
}

variable "ec2_user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = ""
}

variable "ec2_associate_public_ip" {
  description = "Whether to associate a public IP with the public EC2 instance"
  type        = bool
  default     = true
}
