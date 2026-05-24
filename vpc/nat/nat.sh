#!/bin/bash

# Create NAT Gateway
aws ec2 create-nat-gateway \
    --subnet-id subnet-0123456789abcdef0 \  # Replace with your subnet ID
    --allocation-id eipalloc-0123456789abcdef0 \  # Replace with your Elastic IP allocation ID
    --region us-west-2  # Replace with your desired region

# Wait for the NAT Gateway to become available
aws ec2 wait nat-gateway-available \
    --nat-gateway-ids nat-0123456789abcdef0  # Replace with
    --region us-west-2  # Replace with your desired region

# Create a route in the route table to direct traffic to the NAT Gateway
aws ec2 create-route \
    --route-table-id rtb-0123456789abcdef0 \  # Replace with your route table ID
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-0123456789abcdef0 \  # Replace with your NAT Gateway ID
    --region us-west-2  # Replace with your desired region  

# Output the NAT Gateway ID for reference
echo "NAT Gateway created with ID: nat-0123456789abcdef0"



