#!/bin/bash

aws cloudformation deploy \
  --stack-name my-container-lambda-stack \
  --template-file template.yml \
  --capabilities CAPABILITY_NAMED_IAM