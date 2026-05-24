import csv
import json
import boto3

s3 = boto3.client("s3")

OUTPUT_BUCKET = "my-report-output-bucket"

def lambda_handler(event, context):

    bucket = event["bucket"]
    key = event["key"]

    response = s3.get_object(Bucket=bucket, Key=key)

    content = response["Body"].read().decode("utf-8")

    rows = list(csv.DictReader(content.splitlines()))

    sales = [float(row["sales"]) for row in rows]

    stats = {
        "total_sales": sum(sales),
        "average_sales": sum(sales) / len(sales),
        "max_sales": max(sales),
        "min_sales": min(sales),
        "record_count": len(sales)
    }

    output_key = "statistics/stats.json"

    s3.put_object(
        Bucket=OUTPUT_BUCKET,
        Key=output_key,
        Body=json.dumps(stats, indent=2),
        ContentType="application/json"
    )

    return {
        "status": "statistics_generated",
        "stats_file": output_key,
        "output_bucket": OUTPUT_BUCKET,
        "stats": stats,
        "bucket": bucket,
        "key": key
    }