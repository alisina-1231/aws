#!/bin/bash

# Register a job definition with AWS Batch
aws batch register-job-definition \
    --job-definition-name my-job-definition \
    --type container \
    --container-properties '{
        "image": "832014379019.dkr.ecr.us-east-1.amazonaws.com/docker/test:latest",
        "vcpus": 1,
        "memory": 512,
        "command": ["python", "task.py"]
    }'

# Get the job definition ARN
JOB_DEFINITION_ARN=$(aws batch describe-job-definitions \
    --job-definition-name my-job-definition \
    --query 'jobDefinitions[0].jobDefinitionArn' \
    --output text)

# Get subnet ID
SUBNET_ID=$(aws ec2 describe-subnets \
    --query 'Subnets[0].SubnetId' \
    --output text)

# Get security group ID
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

# Create Compute Environment
aws batch create-compute-environment \
    --compute-environment-name my-compute-environment \
    --type MANAGED \
    --state ENABLED \
    --compute-resources '{
        "type": "EC2",
        "minvCpus": 0,
        "maxvCpus": 2,
        "desiredvCpus": 0,
        "instanceTypes": ["t3.small"],
        "subnets": ["'"$SUBNET_ID"'"],
        "securityGroupIds": ["'"$SECURITY_GROUP_ID"'"],
        "instanceRole": "ecsInstanceRole"
    }' \
    --service-role AWSBatchServiceRole

# Wait a bit for compute environment creation
sleep 30

# Create Job Queue
aws batch create-job-queue \
    --job-queue-name my-job-queue \
    --state ENABLED \
    --priority 1 \
    --compute-environment-order order=1,computeEnvironment=my-compute-environment

# Submit a job
JOB_ID=$(aws batch submit-job \
    --job-name my-job \
    --job-queue my-job-queue \
    --job-definition my-job-definition \
    --query 'jobId' \
    --output text)

echo "Submitted Job ID: $JOB_ID"

# Check job status
aws batch describe-jobs \
    --jobs "3715c7bb-6313-4301-8041-98522ca3132a" \
    --query 'jobs[0].status' \
    --output text