import json
from helper.util import format_message

def lambda_handler(event, context):

    name = event.get("name", "Guest")

    message = format_message(name)

    print("Layer output:", message)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": message,
            "input": event
        })
    }