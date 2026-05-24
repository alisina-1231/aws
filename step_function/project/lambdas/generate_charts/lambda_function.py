import boto3
import pandas as pd
import matplotlib.pyplot as plt

s3 = boto3.client("s3")

OUTPUT_BUCKET = "my-report-output-bucket"

def lambda_handler(event, context):

    bucket = event["bucket"]
    key = event["key"]

    response = s3.get_object(Bucket=bucket, Key=key)

    df = pd.read_csv(response["Body"])

    plt.figure(figsize=(8,5))

    plt.bar(df["name"], df["sales"])

    plt.title("Sales by Person")
    plt.xlabel("Name")
    plt.ylabel("Sales")

    chart_path = "/tmp/chart.png"

    plt.savefig(chart_path)

    output_key = "charts/chart.png"

    s3.upload_file(
        chart_path,
        OUTPUT_BUCKET,
        output_key
    )

    return {
        "status": "chart_generated",
        "chart_file": output_key,
        "output_bucket": OUTPUT_BUCKET,
        "bucket": bucket,
        "key": key
    }