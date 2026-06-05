# ============================================================
# General
# ============================================================

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_tag" {
  description = "Project name tag used for all resources"
  type        = string
  default     = "learn-api-gateway"
}

variable "use_existing_iam" {
  description = "Legacy variable (unused, kept for tfvars compatibility)"
  type        = bool
  default     = false
}

# ============================================================
# VPC / Networking
# ============================================================

variable "create_vpc" {
  description = "Whether to create VPC resources (false = use existing)"
  type        = bool
  default     = true
}

variable "main_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["172.16.2.0/24", "172.16.4.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ============================================================
# API Gateway
# ============================================================

variable "api_name" {
  description = "Name of the REST API"
  type        = string
  default     = "calculatePrice"
}

variable "api_description" {
  description = "Description of the REST API"
  type        = string
  default     = "Calculates the price of a house per square meters"
}

variable "api_stage_name" {
  description = "Deployment stage name"
  type        = string
  default     = "dev"
}
