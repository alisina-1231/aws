#!/bin/bash
# zip the code 
zip function.zip lambda_function.py
# Create the lambda function

aws lambda create-function \
  --function-name ProdApiLambda \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::832014379019:role/lambda-basic-role

# Create api Gatway
aws apigatewayv2 create-api \
  --name ProdHttpApi \
  --protocol-type HTTP

# Create Lambda integration
aws apigatewayv2 create-integration \
  --api-id tlpj7y8nk3 \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:lambda:us-east-1:832014379019:function:ProdApiLambda \
  --payload-format-version 2.0

# create route
aws apigatewayv2 create-route \
  --api-id tlpj7y8nk3 \
  --route-key "POST /hello" \
  --target "integrations/9gyln3m"

# Deploy stage
aws apigatewayv2 create-stage \
  --api-id tlpj7y8nk3 \
  --stage-name prod \
  --auto-deploy
# Give API permission to invoke Lambda
aws lambda add-permission \
  --function-name ProdApiLambda \
  --statement-id apigateway-access \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:us-east-1:832014379019:tlpj7y8nk3/*/*/hello"

# Test API
curl -X POST https://tlpj7y8nk3.execute-api.us-east-1.amazonaws.com/prod/hello \
  -H "Content-Type: application/json" \
  -d '{"name":"Ali","city":"Herat"}'