#!/bin/bash
# Create ec2 ami
aws ec2 create-image \
  --instance-id i-12345678 \
  --name "My server image" \
  --description "An AMI for my server" \
  --no-reboot
# Wait for the AMI to be available
aws ec2 wait image-available --image-ids ami-0236922087fa98b6e
# Get security group id
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups  --query 'SecurityGroups[0].GroupId' --output text)

# Create a launch template using the AMI
aws ec2 create-launch-template \
  --launch-template-name my-template \
  --version-description "Version 1" \
  --launch-template-data '{
      "ImageId": "ami-0236922087fa98b6e",
      "InstanceType": "t3.micro",
      "KeyName": "asg",
      "SecurityGroupIds": ["'"$SECURITY_GROUP_ID"'"]
  }'