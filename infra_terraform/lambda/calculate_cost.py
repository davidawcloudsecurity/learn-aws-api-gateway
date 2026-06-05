import json


def lambda_handler(event, context):
    """Calculate cost per unit (price per square meter/foot)."""
    # Non-proxy: API Gateway sends the request body directly as the event
    price = float(event["price"])
    size = float(event["size"])
    unit = event.get("unit", "sqFt")
    down_payment_pct = float(event.get("downPayment", 0))

    price_per_unit = price / size
    down_payment_amount = price * (down_payment_pct / 100)
    total_cost = price - down_payment_amount

    return {
        "pricePerUnit": round(price_per_unit, 2),
        "unit": unit,
        "totalPrice": price,
        "downPaymentPercent": down_payment_pct,
        "downPaymentAmount": down_payment_amount,
        "totalCost": total_cost,
    }
