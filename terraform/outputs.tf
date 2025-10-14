# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_arns" {
  description = "ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_arns" {
  description = "ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.enable_nat_gateway ? aws_route_table.private[*].id : []
}

# VPN Gateway Outputs
output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# DNS Configuration
output "dns_hostnames_enabled" {
  description = "Whether DNS hostnames are enabled"
  value       = aws_vpc.main.enable_dns_hostnames
}

output "dns_support_enabled" {
  description = "Whether DNS support is enabled"
  value       = aws_vpc.main.enable_dns_support
}

# Flow Logs Outputs
output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.vpc[0].id : null
}

output "flow_log_destination" {
  description = "Destination of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.vpc[0].log_destination : null
}

# Common Tags
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Name Prefix
output "name_prefix" {
  description = "Name prefix used for resource naming"
  value       = local.name_prefix
}

# EC2 Instance Outputs
output "public_ec2_instance_id" {
  description = "ID of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_instance.public[0].id : null
}

output "public_ec2_instance_arn" {
  description = "ARN of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_instance.public[0].arn : null
}

output "public_ec2_instance_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_instance.public[0].public_ip : null
}

output "public_ec2_instance_private_ip" {
  description = "Private IP of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_instance.public[0].private_ip : null
}

output "public_ec2_instance_public_dns" {
  description = "Public DNS of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_instance.public[0].public_dns : null
}

output "private_ec2_instance_id" {
  description = "ID of the private EC2 instance"
  value       = var.enable_ec2_instances && var.enable_private_ec2 ? aws_instance.private[0].id : null
}

output "private_ec2_instance_arn" {
  description = "ARN of the private EC2 instance"
  value       = var.enable_ec2_instances && var.enable_private_ec2 ? aws_instance.private[0].arn : null
}

output "private_ec2_instance_private_ip" {
  description = "Private IP of the private EC2 instance"
  value       = var.enable_ec2_instances && var.enable_private_ec2 ? aws_instance.private[0].private_ip : null
}

output "private_ec2_instance_private_dns" {
  description = "Private DNS of the private EC2 instance"
  value       = var.enable_ec2_instances && var.enable_private_ec2 ? aws_instance.private[0].private_dns : null
}

# Security Group Outputs
output "public_ec2_security_group_id" {
  description = "ID of the public EC2 security group"
  value       = var.enable_ec2_instances && var.enable_public_ec2 ? aws_security_group.public_ec2[0].id : null
}

output "private_ec2_security_group_id" {
  description = "ID of the private EC2 security group"
  value       = var.enable_ec2_instances && var.enable_private_ec2 ? aws_security_group.private_ec2[0].id : null
}

# Elastic IP Outputs
output "public_ec2_eip" {
  description = "Elastic IP of the public EC2 instance"
  value       = var.enable_ec2_instances && var.enable_public_ec2 && var.ec2_associate_public_ip ? aws_eip.public_ec2[0].public_ip : null
}

output "public_ec2_eip_allocation_id" {
  description = "Allocation ID of the public EC2 Elastic IP"
  value       = var.enable_ec2_instances && var.enable_public_ec2 && var.ec2_associate_public_ip ? aws_eip.public_ec2[0].allocation_id : null
}
