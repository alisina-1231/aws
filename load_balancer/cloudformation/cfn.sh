#!/bin/bash
aws cloudformation create-stack \
  --stack-name alb-asg-demo \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM