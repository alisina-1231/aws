#!/bin/bash
# Create a CloudFormation stack using the template.yaml file
STACK_NAME="SQSStandardQueueStack"
TEMPLATE_FILE="/home/ali/aws/sqs/fifo/cloudformation/template.yaml"

aws cloudformation create-stack --stack-name $STACK_NAME \
--template-body file://$TEMPLATE_FILE \
--capabilities CAPABILITY_NAMED_IAM
