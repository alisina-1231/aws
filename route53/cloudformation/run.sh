aws cloudformation create-stack \
--stack-name route53-lab \
--template-body file://template.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters \
ParameterKey=KeyPair,ParameterValue=route53 \
ParameterKey=DomainName,ParameterValue=example.com