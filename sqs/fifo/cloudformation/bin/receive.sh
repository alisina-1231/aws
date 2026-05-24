#!/bin/bash
# This script receives messages from the SQS queue defined in the CloudFormation template.
# Set the queue URL (replace with your actual queue URL)
QUEUE_URL="https://sqs.us-east-1.amazonaws.com/832014379019/MyFifoQueue.fifo"
# Receive messages from the SQS queue
aws sqs receive-message --queue-url $QUEUE_URL --max-number-of-messages 10 --wait-time-seconds 20