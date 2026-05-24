#!/bin/bash
# Create a Lambda function with inline code using AWS CLI
aws lambda create-function \
  --function-name inline-lambda \
  --runtime python3.12 \
  --handler index.lambda_handler \
  --role arn:aws:iam::832014379019:role/lambda-basic-role \
  --zip-file "fileb://function.zip"