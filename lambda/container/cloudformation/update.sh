#!/bin/bash
aws cloudformation update-stack \
  --stack-name my-container-lambda-stack \
  --template-body file://template.yml \
  --capabilities CAPABILITY_NAMED_IAM