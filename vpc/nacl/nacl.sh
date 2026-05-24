#!/bin/bash

# Create Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-0123456789abcdef0 \  # Replace with your VPC ID
    --region us-west-2  # Replace with your desired region
# Create a Network ACL entry to allow inbound HTTP traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-0123456789abcdef0 \  # Replace with
    --rule-number 100 \
    --protocol tcp \
    --port-range From=80,To=80 \   
    --egress \
    --rule-action allow \
    --region us-west-2  # Replace with your desired region
# Create a Network ACL entry to allow inbound HTTPS traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-0123456789abcdef0 \  # Replace with
    --rule-number 110 \
    --protocol tcp \
    --port-range From=443,To=443 \   
    --egress \
    --rule-action allow \
    --region us-west-2  # Replace with your desired region
# Create a Network ACL entry to allow outbound traffic to the internet
aws ec2 create-network-acl-entry \
    --network-acl-id acl-0123456789abcdef0 \  # Replace with
    --rule-number 100 \
    --protocol -1 \
    --egress \  
    --rule-action allow \
    --region us-west-2  # Replace with your desired region 
# Output the Network ACL ID for reference
echo "Network ACL created with ID: acl-0123456789abcdef0"

# Attach ACL to Subnet
aws ec2 associate-network-acl \
    --network-acl-id acl-0123456789abcdef0 \  # Replace with your Network ACL ID
    --subnet-id subnet-0123456789abcdef0 \  # Replace with your subnet ID
    --region us-west-2  # Replace with your
    desired region 
echo "Network ACL associated with subnet: subnet-0123456789abcdef0"