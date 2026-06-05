region          = "us-east-1"
project_tag     = "learn-api-gateway"
main_cidr_block = "172.16.0.0/16"

# VPC
create_vpc = true

# API Gateway
api_name        = "calculatePrice"
api_description = "Calculates the price of a house per square meters"
api_stage_name  = "dev"
