import json

def lambda_handler(event, context):

    print("Received event:", json.dumps(event))

    body = event.get("body")

    # API Gateway sends body as string
    if body:
        body = json.loads(body)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Hello from production API",
            "input": body
        })
    }