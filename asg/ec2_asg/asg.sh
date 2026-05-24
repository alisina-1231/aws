#!/bin/bash
# Get subnet ids for the Auto Scaling group
SUBNET_ID1=$(aws ec2 describe-subnets --query 'Subnets[0:1].SubnetId' --output text)
SUBNET_ID2=$(aws ec2 describe-subnets --query 'Subnets[1:2].SubnetId' --output text)

# Create an Auto Scaling group using a launch template
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --launch-template LaunchTemplateName=my-template,Version=1 \
  --min-size 2 \
  --max-size 6 \
  --desired-capacity 3 \
  --vpc-zone-identifier "$SUBNET_ID1,$SUBNET_ID2"

# Update the Auto Scaling group to use ELB health checks
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name my-asg \
  --health-check-type ELB \
  --health-check-grace-period 300

# Create a scaling policy to scale out when CPU utilization exceeds 70%
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name scale-out-policy \
  --adjustment-type ChangeInCapacity \
  --scaling-adjustment 1

# Create a target tracking scaling policy for CPU utilization
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name my-asg \
  --policy-name cpu-target-tracking \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
      "PredefinedMetricSpecification": {
          "PredefinedMetricType": "ASGAverageCPUUtilization"
      },
      "TargetValue": 50.0
  }'
