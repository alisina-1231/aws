aws cloudformation update-stack \
  --stack-name my-inline-lambda-stack \
  --template-body file://template.yml \
  --capabilities CAPABILITY_NAMED_IAM