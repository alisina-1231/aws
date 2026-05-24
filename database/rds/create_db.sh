#!/bin/bash

# ==========================================
# Simple Public RDS Test Environment
# PostgreSQL + MySQL
# ==========================================

REGION="us-east-1"

VPC_CIDR="10.10.0.0/16"
PUBLIC_SUBNET_CIDR="10.10.1.0/24"

AZ="us-east-1a"

POSTGRES_DB_ID="test-postgres-instance"
MYSQL_DB_ID="test-mysql-instance"

DB_PASSWORD="password"

# ==========================================
# Create VPC
# ==========================================

echo "Creating VPC..."

VPC_ID=$(aws ec2 create-vpc \
    --cidr-block $VPC_CIDR \
    --region $REGION \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: $VPC_ID"

# Enable DNS
aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
    --vpc-id $VPC_ID \
    --enable-dns-hostnames "{\"Value\":true}"

# ==========================================
# Create Public Subnet
# ==========================================

echo "Creating Public Subnet..."

SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block $PUBLIC_SUBNET_CIDR \
    --availability-zone $AZ \
    --region $REGION \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Subnet ID: $SUBNET_ID"

# Enable Public IP Assignment
aws ec2 modify-subnet-attribute \
    --subnet-id $SUBNET_ID \
    --map-public-ip-on-launch

# ==========================================
# Create Internet Gateway
# ==========================================

echo "Creating Internet Gateway..."

IGW_ID=$(aws ec2 create-internet-gateway \
    --region $REGION \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

echo "IGW ID: $IGW_ID"

aws ec2 attach-internet-gateway \
    --vpc-id $VPC_ID \
    --internet-gateway-id $IGW_ID

# ==========================================
# Create Route Table
# ==========================================

echo "Creating Route Table..."

ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --region $REGION \
    --query 'RouteTable.RouteTableId' \
    --output text)

echo "Route Table ID: $ROUTE_TABLE_ID"

aws ec2 create-route \
    --route-table-id $ROUTE_TABLE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

aws ec2 associate-route-table \
    --route-table-id $ROUTE_TABLE_ID \
    --subnet-id $SUBNET_ID

# ==========================================
# Create Security Group
# ==========================================

echo "Creating Security Group..."

SG_ID=$(aws ec2 create-security-group \
    --group-name database-sg \
    --description "RDS public access SG" \
    --vpc-id $VPC_ID \
    --region $REGION \
    --query 'GroupId' \
    --output text)

echo "Security Group ID: $SG_ID"

# PostgreSQL Access
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 5432 \
    --cidr 0.0.0.0/0

# MySQL Access
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 3306 \
    --cidr 0.0.0.0/0

# ==========================================
# Create DB Subnet Group
# ==========================================

echo "Creating DB Subnet Group..."

aws rds create-db-subnet-group \
    --db-subnet-group-name database-subnet-group \
    --db-subnet-group-description "Test subnet group" \
    --subnet-ids $SUBNET_ID \
    --region $REGION

# ==========================================
# Create PostgreSQL RDS
# ==========================================

echo "Creating PostgreSQL..."

aws rds create-db-instance \
    --db-instance-identifier $POSTGRES_DB_ID \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --allocated-storage 20 \
    --master-username password \
    --master-user-password $DB_PASSWORD \
    --vpc-security-group-ids $SG_ID \
    --db-subnet-group-name database-subnet-group \
    --publicly-accessible \
    --backup-retention-period 0 \
    --region $REGION

# ==========================================
# Create MySQL RDS
# ==========================================

echo "Creating MySQL..."

aws rds create-db-instance \
    --db-instance-identifier $MYSQL_DB_ID \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --allocated-storage 20 \
    --master-username admin \
    --master-user-password $DB_PASSWORD \
    --vpc-security-group-ids $SG_ID \
    --db-subnet-group-name database-subnet-group \
    --publicly-accessible \
    --backup-retention-period 0 \
    --region $REGION

# ==========================================
# Wait for Databases
# ==========================================

echo "Waiting for PostgreSQL..."

aws rds wait db-instance-available \
    --db-instance-identifier $POSTGRES_DB_ID \
    --region $REGION

echo "Waiting for MySQL..."

aws rds wait db-instance-available \
    --db-instance-identifier $MYSQL_DB_ID \
    --region $REGION

# ==========================================
# Show Endpoints
# ==========================================

echo "PostgreSQL Endpoint:"

aws rds describe-db-instances \
    --db-instance-identifier $POSTGRES_DB_ID \
    --query 'DBInstances[0].Endpoint.Address' \
    --region $REGION \
    --output text

echo "MySQL Endpoint:"

aws rds describe-db-instances \
    --db-instance-identifier $MYSQL_DB_ID \
    --query 'DBInstances[0].Endpoint.Address' \
    --region $REGION \
    --output text

echo "All Done."