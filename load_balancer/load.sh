#!/bin/bash
# Get subnet ids for the Auto Scaling group
subnet_id1=$(aws ec2 describe-subnets --query 'Subnets[0:1].SubnetId' --output text)
subnet_id2=$(aws ec2 describe-subnets --query 'Subnets[1:2].SubnetId' --output text)
vpcid=$(aws ec2 describe-vpcs --query 'Vpcs[0].VpcId' --output text)
id1=$(aws ec2 describe-instances --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
id2=$(aws ec2 describe-instances --query 'Reservations[1].Instances[0].PrivateIpAddress' --output text)
# Create NLB
loadarn=$(aws elbv2 create-load-balancer --name my-nlb \
--type network \
--subnets "$subnet_id1" "$subnet_id2" \
--query 'LoadBalancers[0].LoadBalancerArn' --output text)

# Create Target Group
targetarn=$(aws elbv2 create-target-group \
--name my-targets --protocol TCP --port 80 \
--target-type ip --vpc-id $vpcid
--query 'TargetGroups[0].TargetGroupArn' --output text)

# Register Targets
aws elbv2 register-targets \
--target-group-arn "$targetarn" \
--targets Id=$id1 Id=$id2
# Create Listener
aws elbv2 create-listener \
--load-balancer-arn "$loadarn" \
--protocol TCP --port 800 \
--default-actions Type=forward,TargetGroupArn="$targetarn"

# Output the DNS name of the NLB
aws elbv2 describe-load-balancers --names my-nlb --query 'LoadBalancers[0].DNSName' --output text


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


# Attach the NLB to the Auto Scaling group
aws autoscaling attach-load-balancers \
--auto-scaling-group-name my-asg \
--load-balancer-names my-nlb