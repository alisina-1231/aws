aws lambda create-function \
  --function-name hello-world \
  --package-type Image \
  --code ImageUri=832014379019.dkr.ecr.us-east-1.amazonaws.com/lambda-container:v3 \
  --role arn:aws:iam::832014379019:role/lambda-basic-role