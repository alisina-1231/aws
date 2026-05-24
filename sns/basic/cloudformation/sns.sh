aws cloudformation create-stack \
  --stack-name sns-lambda-stack \
  --template-body file://sns_lambda.yaml \
  --capabilities CAPABILITY_NAMED_IAM

  aws cloudformation wait stack-create-complete \
  --stack-name sns-lambda-stack

  aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:832014379019:my-sns-topic \
  --message "Hello from SNS"