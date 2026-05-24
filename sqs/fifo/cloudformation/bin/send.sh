#!/bin/bash
# This script sends a message to the SQS queue defined in the CloudFormation template.
# Set the queue URL (replace with your actual queue URL)
QUEUE_URL="https://sqs.us-east-1.amazonaws.com/832014379019/MyFifoQueue.fifo"
# Set the message body
MESSAGE_BODY="Hello, this is a test message from the send script!"
# Send the message to the SQS queue
aws sqs send-message --queue-url $QUEUE_URL --message-body "$MESSAGE_BODY" --message-group-id "group1"