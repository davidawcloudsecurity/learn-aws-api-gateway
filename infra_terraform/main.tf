provider "aws" {
  region = var.region
}

# ============================================================
# VPC + Networking (2 AZs)
# ============================================================

resource "aws_vpc" "main" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.main_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = var.project_tag }
}

locals {
  vpc_id = var.create_vpc ? aws_vpc.main[0].id : data.aws_vpc.existing[0].id
}

data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "tag:Name"
    values = [var.project_tag]
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id
  tags   = { Name = "${var.project_tag}-igw" }
}

resource "aws_subnet" "public" {
  count                   = var.create_vpc ? length(var.public_subnet_cidrs) : 0
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_tag}-public-${var.azs[count.index]}" }
}

resource "aws_subnet" "private" {
  count             = var.create_vpc ? length(var.private_subnet_cidrs) : 0
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = { Name = "${var.project_tag}-private-${var.azs[count.index]}" }
}

# NAT Gateway — instances in private subnets need outbound access
resource "aws_eip" "nat" {
  count  = var.create_vpc ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.project_tag}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_vpc ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project_tag}-nat-gw", "auto-delete" = "no" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = { Name = "${var.project_tag}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = var.create_vpc ? length(aws_subnet.public) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = local.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }
  tags = { Name = "${var.project_tag}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = var.create_vpc ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# ============================================================
# Outputs
# ============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}
