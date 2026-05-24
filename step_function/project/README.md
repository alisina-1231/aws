Here’s a **clean, professional, GitHub-ready README.md** based on your project. I organized it, fixed structure, improved readability, and grouped everything logically.

---

# 📊 CSV Processing Pipeline (AWS Step Functions + Lambda)

This project implements a fully serverless **CSV processing pipeline** using AWS services:

* S3 (input/output storage)
* Lambda (data processing)
* Step Functions (workflow orchestration)
* CloudWatch (logging)
* ECR (container-based Lambda)

---

# 🏗️ Architecture Overview

```
S3 Upload (CSV)
      ↓
Validate CSV (Lambda)
      ↓
Parallel Processing
   ├── Generate Statistics (Lambda)
   └── Generate Charts (Lambda / Container)
      ↓
Generate PDF Report (Lambda / Container)
      ↓
Store Output in S3
```

---

# 📁 Project Structure

```
project/
│
├── lambdas/
│   ├── validate_csv/
│   ├── generate_stats/
│   ├── generate_charts/
│   ├── generate_pdf/
│   └── docker/
│
├── stepfunctions/
│   └── workflow.json
│
├── sample-data/
│   └── sales.csv
│
├── outputs/
│
└── roles/
```

---

# 🚀 Setup Instructions

## 1. Create S3 Buckets

```bash
aws s3 mb s3://my-csv-input-bucket-1231
aws s3 mb s3://my-report-output-bucket
```

### Upload sample data

```bash
aws s3 cp sample-data/sales.csv s3://my-csv-input-bucket-1231/
```

---

# 🔐 IAM Role Setup

## Create IAM Role

```bash
aws iam create-role \
  --role-name csv-processing-lambda-role \
  --assume-role-policy-document file://trust.json
```

## Attach Policies

```bash
aws iam attach-role-policy \
  --role-name csv-processing-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

```bash
aws iam attach-role-policy \
  --role-name csv-processing-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

---

# ⚙️ Lambda Functions

---

## 1. Validate CSV

```bash
aws lambda create-function \
  --function-name validate-csv \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::832014379019:role/csv-processing-lambda-role
```

### Test

```bash
aws lambda invoke \
  --function-name validate-csv \
  --payload file://event.json \
  output.json
```

---

## 2. Generate Statistics

```bash
aws lambda create-function \
  --function-name generate-statistics \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::832014379019:role/csv-processing-lambda-role
```

### Test

```bash
aws lambda invoke \
  --function-name generate-statistics \
  --payload file://event.json \
  output.json
```

---

## 3. Generate Charts

### Option A: Lambda Layer (Matplotlib)

```bash
mkdir python
pip install matplotlib pandas -t python/
zip -r layer.zip python
```

```bash
aws lambda publish-layer-version \
  --layer-name data-science-layer \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.12
```

---

### Option B: Container Image (Recommended)

```bash
docker build -t lambda-chart .
```

Push to ECR, then:

```bash
aws lambda create-function \
  --function-name generate-charts \
  --package-type Image \
  --code ImageUri=832014379019.dkr.ecr.us-east-1.amazonaws.com/lambda/stepfunction-1231:latest \
  --role arn:aws:iam::832014379019:role/csv-processing-lambda-role
```

### Test

```bash
aws lambda invoke \
  --function-name generate-charts \
  --payload file://event.json \
  output.json
```

---

## 4. Generate PDF Report

### Container-based Lambda

```bash
aws lambda create-function \
  --function-name generate-pdf \
  --package-type Image \
  --code ImageUri=832014379019.dkr.ecr.us-east-1.amazonaws.com/lambda/stepfunction-1231:v1 \
  --role arn:aws:iam::832014379019:role/csv-processing-lambda-role
```

### Test

```bash
aws lambda invoke \
  --function-name generate-pdf \
  --payload '{}' \
  output.json
```

---

# 🔄 Step Functions Workflow

## Deploy Workflow

Use:

```bash
stepfunctions/workflow.json
```

Then create state machine in AWS Step Functions console or CLI.

