# Publish Layer
aws lambda publish-layer-version \
  --layer-name python-helper-layer \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.12

# Create Lambda
aws lambda create-function \
  --function-name PythonLayerLambda \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::832014379019:role/lambda-basic-role

# Invoke Function
aws lambda invoke   --function-name PythonLayerLambda   --payload ewogICAgIm5hbWUiOiAgICAiQWxpIgp9Cg== 
  response.json