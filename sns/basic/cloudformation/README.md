# SNS Trigger Lambda with CloudFormation

This project deploys an AWS infrastructure stack using CloudFormation that connects Amazon SNS to AWS Lambda and stores logs in CloudWatch Logs.

---

# Architecture

```text
Amazon SNS
    ↓
AWS Lambda
    ↓
CloudWatch Logs
```

---

# Features

- Create SNS Topic
- Create Lambda Function
- Subscribe Lambda to SNS
- Automatically grant invoke permissions
- Store Lambda logs in CloudWatch
- Fully automated with CloudFormation

---

# Prerequisites

Before deploying, ensure you have:

- AWS CLI installed
- AWS account configured
- IAM permissions for:
  - CloudFormation
  - Lambda
  - SNS
  - IAM
  - CloudWatch Logs

Configure AWS credentials:

```bash
aws configure
```

---

# Files

```text
.
├── sns-lambda.yaml
└── README.md
```

---

# Deploy the Stack

## Create Stack

```bash
aws cloudformation create-stack \
  --stack-name sns-lambda-stack \
  --template-body file://sns-lambda.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

# Wait for Deployment

```bash
aws cloudformation wait stack-create-complete \
  --stack-name sns-lambda-stack
```

---

# Verify Resources

## List SNS Topics

```bash
aws sns list-topics
```

## List Lambda Functions

```bash
aws lambda list-functions
```

---

# Publish Test Message

Replace the Topic ARN with your actual ARN.

```bash
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:123456789012:my-sns-topic \
  --message "Hello from SNS"
```

---

# Check CloudWatch Logs

## List Log Groups

```bash
aws logs describe-log-groups
```

Expected log group:

```text
/aws/lambda/my-sns-lambda
```

---

## Stream Logs

```bash
aws logs tail /aws/lambda/my-sns-lambda --follow
```

Expected output:

```text
=== EVENT RECEIVED ===

SNS Message: Hello from SNS
```

---

# CloudFormation Outputs

The stack outputs:

| Output | Description |
|--------|-------------|
| TopicArn | SNS Topic ARN |
| LambdaName | Lambda Function Name |

Retrieve outputs:

```bash
aws cloudformation describe-stacks \
  --stack-name sns-lambda-stack
```

---

# Delete the Stack

```bash
aws cloudformation delete-stack \
  --stack-name sns-lambda-stack
```

---

# AWS Services Used

- Amazon SNS
- AWS Lambda
- Amazon CloudWatch Logs
- AWS CloudFormation
- AWS IAM

---

# Learning Objectives

This project demonstrates:

- Event-driven architecture
- Serverless computing
- SNS to Lambda integration
- CloudFormation Infrastructure as Code (IaC)
- CloudWatch logging and monitoring

---

# Future Improvements

You can extend this project by adding:

- Email subscription
- SQS integration
- Dead Letter Queue (DLQ)
- Lambda environment variables
- Retry policy
- SNS FIFO topics
- CloudWatch alarms
- Terraform version
- Go runtime Lambda
- API Gateway integration

---

# Author

Created for AWS serverless and CloudFormation practice.