aws cloudformation create-stack \
  --stack-name lambda-sns-stack \
  --template-body file://lambda_sns.yaml \
  --parameters ParameterKey=EmailAddress,ParameterValue=example@gmail.com \
  --capabilities CAPABILITY_NAMED_IAM

  aws lambda invoke \
  --function-name MyLambdaFunction \
  output.json

  aws sns list-topics

  aws logs describe-log-groups