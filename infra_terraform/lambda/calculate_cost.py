import json


def lambda_handler(event, context):
    """Calculate cost per unit (price per square meter/foot)."""
    try:
        body = event if isinstance(event, dict) else json.loads(event.get("body", "{}"))

        price = float(body["price"])
        size = float(body["size"])
        unit = body.get("unit", "sqFt")
        down_payment_pct = float(body.get("downPayment", 0))

        price_per_unit = price / size
        down_payment_amount = price * (down_payment_pct / 100)
        total_cost = price - down_payment_amount

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "pricePerUnit": round(price_per_unit, 2),
                "unit": unit,
                "totalPrice": price,
                "downPaymentPercent": down_payment_pct,
                "downPaymentAmount": down_payment_amount,
                "totalCost": total_cost,
            }),
        }
    except (KeyError, ValueError, TypeError) as e:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
        }
