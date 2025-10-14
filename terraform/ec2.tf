# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  count = var.enable_ec2_instances ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for Public EC2 Instance
resource "aws_security_group" "public_ec2" {
  count = var.enable_ec2_instances && var.enable_public_ec2 ? 1 : 0

  name_prefix = "${local.name_prefix}-public-ec2-"
  vpc_id      = aws_vpc.main.id

  # SSH access from anywhere (customize as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-ec2-sg"
      Type = "public"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Private EC2 Instance
resource "aws_security_group" "private_ec2" {
  count = var.enable_ec2_instances && var.enable_private_ec2 ? 1 : 0

  name_prefix = "${local.name_prefix}-private-ec2-"
  vpc_id      = aws_vpc.main.id

  # SSH access only from VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH access from VPC"
  }

  # HTTP access only from VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTP access from VPC"
  }

  # HTTPS access only from VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS access from VPC"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-ec2-sg"
      Type = "private"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Public EC2 Instance
resource "aws_instance" "public" {
  count = var.enable_ec2_instances && var.enable_public_ec2 ? 1 : 0

  ami                    = var.ec2_ami_id != "" ? var.ec2_ami_id : data.aws_ami.amazon_linux[0].id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.public_ec2[0].id]
  associate_public_ip_address = var.ec2_associate_public_ip

  root_block_device {
    volume_type           = var.ec2_root_volume_type
    volume_size           = var.ec2_root_volume_size
    encrypted             = var.ec2_root_volume_encrypted
    delete_on_termination  = true
  }

  user_data = var.ec2_user_data != "" ? var.ec2_user_data : <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Public EC2 Instance!</h1>" > /var/www/html/index.html
    EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-ec2"
      Type = "public"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Private EC2 Instance
resource "aws_instance" "private" {
  count = var.enable_ec2_instances && var.enable_private_ec2 ? 1 : 0

  ami                    = var.ec2_ami_id != "" ? var.ec2_ami_id : data.aws_ami.amazon_linux[0].id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name != "" ? var.ec2_key_name : null
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_ec2[0].id]

  root_block_device {
    volume_type           = var.ec2_root_volume_type
    volume_size           = var.ec2_root_volume_size
    encrypted             = var.ec2_root_volume_encrypted
    delete_on_termination  = true
  }

  user_data = var.ec2_user_data != "" ? var.ec2_user_data : <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Private EC2 Instance!</h1>" > /var/www/html/index.html
    EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-ec2"
      Type = "private"
    }
  )

  depends_on = [aws_nat_gateway.main]
}

# Elastic IP for Public EC2 Instance (optional)
resource "aws_eip" "public_ec2" {
  count = var.enable_ec2_instances && var.enable_public_ec2 && var.ec2_associate_public_ip ? 1 : 0

  instance = aws_instance.public[0].id
  domain   = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-ec2-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}
