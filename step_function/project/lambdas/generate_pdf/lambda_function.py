import json
import boto3

from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Image
)

from reportlab.lib.styles import getSampleStyleSheet

s3 = boto3.client("s3")

OUTPUT_BUCKET = "my-report-output-bucket"

def lambda_handler(event, context):

    stats_key = "statistics/stats.json"
    chart_key = "charts/chart.png"

    # Download statistics
    stats_obj = s3.get_object(
        Bucket=OUTPUT_BUCKET,
        Key=stats_key
    )

    stats = json.loads(
        stats_obj["Body"].read().decode("utf-8")
    )

    # Download chart image
    chart_path = "/tmp/chart.png"

    s3.download_file(
        OUTPUT_BUCKET,
        chart_key,
        chart_path
    )

    # PDF output path
    pdf_path = "/tmp/report.pdf"

    doc = SimpleDocTemplate(pdf_path)

    styles = getSampleStyleSheet()

    elements = []

    title = Paragraph(
        "Sales Analysis Report",
        styles["Title"]
    )

    elements.append(title)

    elements.append(Spacer(1, 20))

    # Add statistics
    for key, value in stats.items():

        line = Paragraph(
            f"<b>{key}</b>: {value}",
            styles["BodyText"]
        )

        elements.append(line)

        elements.append(Spacer(1, 10))

    # Add chart image
    img = Image(chart_path, width=400, height=250)

    elements.append(img)

    # Build PDF
    doc.build(elements)

    # Upload PDF to S3
    output_key = "reports/final-report.pdf"

    s3.upload_file(
        pdf_path,
        OUTPUT_BUCKET,
        output_key
    )

    return {
        "status": "pdf_generated",
        "pdf_file": output_key,
        "output_bucket": OUTPUT_BUCKET
    }