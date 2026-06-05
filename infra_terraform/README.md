# AWS API Gateway + Lambda (Terraform)

## Architecture

```
Client
  │
  ▼ POST /pricePerMeter
┌─────────────────────────────────┐
│  API Gateway (REST, Regional)   │
│  API: calculatePrice            │
│  Resource: /pricePerMeter       │
│  Method: POST (Lambda Proxy)    │
└─────────────────┬───────────────┘
                  │
                  ▼
┌─────────────────────────────────┐
│  Lambda: CalculateCostPerUnit   │
│  Runtime: Python 3.12           │
│  Returns: pricePerUnit,         │
│           totalCost,            │
│           downPaymentAmount     │
└─────────────────────────────────┘
```

## What It Does

- REST API with a `POST /pricePerMeter` endpoint
- Lambda calculates price per unit and total cost after down payment
- Sample request:

```json
{
  "price": "400000",
  "size": "1600",
  "unit": "sqFt",
  "downPayment": "20"
}
```

- Sample response:

```json
{
  "pricePerUnit": 250.0,
  "unit": "sqFt",
  "totalPrice": 400000.0,
  "downPaymentPercent": 20.0,
  "downPaymentAmount": 80000.0,
  "totalCost": 320000.0
}
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

After apply, test with curl:

```bash
curl -X POST \
  "$(terraform output -raw api_gateway_url)" \
  -H "Content-Type: application/json" \
  -d '{"price":"400000","size":"1600","unit":"sqFt","downPayment":"20"}'
```

## Files

| File | Purpose |
|------|---------|
| `main.tf` | VPC networking + Lambda + API Gateway |
| `variables.tf` | Input variables |
| `terraform.tfvars` | Variable values |
| `lambda/calculate_cost.py` | Lambda function source |

## Cost

| Resource | Cost |
|----------|------|
| API Gateway | Free tier: 1M calls/month |
| Lambda | Free tier: 1M requests/month |
| NAT Gateway | ~$32/month + data |
| VPC | Free |
