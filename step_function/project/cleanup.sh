#!/bin/bash

set -e

echo "🚨 Starting AWS CSV Pipeline Cleanup..."

ACCOUNT_ID="832014379019"
REGION="us-east-1"
ROLE_NAME="csv-processing-lambda-role"

STEP_FUNCTION_NAME="CSVProcessingStateMachine"

LAMBDA_FUNCTIONS=(
  "validate-csv"
  "generate-statistics"
  "generate-charts"
  "generate-pdf"
)

echo "======================================"
echo "🧹 1. Deleting Step Functions"
echo "======================================"

STATE_MACHINE_ARN=$(aws stepfunctions list-state-machines \
  --query "stateMachines[?name=='$STEP_FUNCTION_NAME'].stateMachineArn" \
  --output text)

if [ "$STATE_MACHINE_ARN" != "None" ] && [ -n "$STATE_MACHINE_ARN" ]; then
  aws stepfunctions delete-state-machine \
    --state-machine-arn "$STATE_MACHINE_ARN"
  echo "✔ Deleted Step Function"
else
  echo "⚠ Step Function not found"
fi

echo "======================================"
echo "🧹 2. Deleting Lambda Functions"
echo "======================================"

for fn in "${LAMBDA_FUNCTIONS[@]}"; do
  aws lambda delete-function --function-name "$fn" || echo "⚠ $fn not found"
done

echo "✔ Lambda cleanup done"

echo "======================================"
echo "🧹 3. Detaching IAM Policies"
echo "======================================"

aws iam detach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true

aws iam detach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess || true

echo "✔ IAM policies detached"

echo "======================================"
echo "🧹 4. Deleting IAM Role"
echo "======================================"

aws iam delete-role --role-name $ROLE_NAME || echo "⚠ Role not found or in use"

echo "======================================"
echo "🧹 5. Empty & Delete S3 Buckets"
echo "======================================"

BUCKETS=(
  "my-csv-input-bucket-1231"
  "my-report-output-bucket"
)

for bucket in "${BUCKETS[@]}"; do
  echo "Cleaning bucket: $bucket"

  aws s3 rm "s3://$bucket" --recursive || true
  aws s3 rb "s3://$bucket" || true
done

echo "✔ S3 cleanup done"

echo "======================================"
echo "🧹 6. (Optional) Clean ECR Images"
echo "======================================"

ECR_REPO="lambda/stepfunction-1231"

IMAGE_IDS=$(aws ecr list-images \
  --repository-name "$ECR_REPO" \
  --query 'imageIds[*]' \
  --output json 2>/dev/null || true)

if [ "$IMAGE_IDS" != "[]" ] && [ -n "$IMAGE_IDS" ]; then
  aws ecr batch-delete-image \
    --repository-name "$ECR_REPO" \
    --image-ids "$IMAGE_IDS" || true
  echo "✔ ECR images deleted"
else
  echo "⚠ No ECR images found"
fi

echo "======================================"
echo "🎉 CLEANUP COMPLETE"
echo "======================================"