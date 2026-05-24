#!/bin/bash

# Create sns Topic
aws sns create-topic --name MyTopic
# Subscribe to the topic
aws sns subscribe --topic-arn arn:aws:sns:us-east-1:832014379019:MySNSTopic \
--protocol email --notification-endpoint myemail@example.com