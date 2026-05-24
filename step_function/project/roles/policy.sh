aws iam create-role \
  --role-name csv-processing-lambda-role \
  --assume-role-policy-document fileb://trust.json

  aws iam attach-role-policy \
  --role-name csv-processing-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

  aws iam attach-role-policy \
  --role-name csv-processing-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess