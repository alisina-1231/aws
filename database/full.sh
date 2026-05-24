aws cloudformation create-stack \
  --stack-name dms-lab-stack-test \
  --template-body file://full.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters \
    ParameterKey=DBPassword,ParameterValue=password