#!/bin/bash

echo "Deploying VPC Gateway"

aws ec2 create-vpc --cidr-block 10.10.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=VPC-Gateway}]' \
    --query 'Vpc.VpcId' \
    --output text

echo "VPC created"

echo "Creating Subnet"
aws ec2 create-subnet --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text) \
    --cidr-block 10.10.1.0/24 \
    --query 'Subnet.SubnetId' \
    --output text

echo "Subnet created"

echo "Creating Internet Gateway"
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=IGW-Gateway}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text   

echo "Internet Gateway created"

echo "Attaching Internet Gateway to VPC"

aws ec2 attach-internet-gateway \
--internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=IGW-Gateway" \
--query 'InternetGateways[0].InternetGatewayId' --output text) \
--vpc-id $(aws ec2 describe-vpcs \
--filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text)

echo "Internet Gateway attached to VPC"

echo "Creating Route Table"
aws ec2 create-route-table \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text) \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=RT-Gateway}]' \
--query 'RouteTable.RouteTableId' \
--output text

echo "Route Table created"

echo "Creating Route to Internet Gateway"
aws ec2 create-route \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:   Name,Values=RT-Gateway" \
--query 'RouteTables[0].RouteTableId' --output text) \  
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=IGW-Gateway" \
--query 'InternetGateways[0].InternetGatewayId' --output text)
echo "Route to Internet Gateway created"


echo "Associating Route Table with Subnet"
aws ec2 associate-route-table \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag: Name,Values=RT-Gateway" \
--query 'RouteTables[0].RouteTableId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Subnet-Gateway" \
--query 'Subnets[0].SubnetId' --output text)

echo "Route Table associated with Subnet"

echo "VPC Gateway deployment complete"

echo "Creating Security Group"
aws ec2 create-security-group \
--group-name SG-Gateway \
--description "Security group for VPC Gateway" \   
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC-Gateway" \
--query 'Vpcs[0].VpcId' --output text) \
--tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=SG-Gateway}]' \
--query 'GroupId' \
--output text

echo "Security Group created"

echo "Allowing inbound SSH traffic on port 22"
aws ec2 authorize-security-group-ingress \
--group-id $(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=SG-Gateway" \
--query 'SecurityGroups[0].GroupId' --output text) \
--protocol tcp \
--port 22 \
--cidr-block 0.0.0.0/0 \
echo "Inbound SSH traffic allowed"
