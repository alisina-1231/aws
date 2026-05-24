import csv
import json
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):

    bucket = event["bucket"]
    key = event["key"]

    response = s3.get_object(Bucket=bucket, Key=key)

    content = response["Body"].read().decode("utf-8")

    rows = list(csv.DictReader(content.splitlines()))

    if len(rows) == 0:
        raise Exception("CSV is empty")

    required_columns = ["name", "sales", "month"]

    for col in required_columns:
        if col not in rows[0]:
            raise Exception(f"Missing column: {col}")

    for row in rows:
        for col in required_columns:
            if row[col] == "":
                raise Exception(f"Null value found in {col}")

    return {
        "status": "validated",
        "bucket": bucket,
        "key": key,
        "rows": len(rows)
    }