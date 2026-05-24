#!/bin/bash

set -e

echo "Starting Valkey ElastiCache setup..."

# CONFIG VARIABLES

REGION="us-east-1"
CACHE_NAME="valkey-lab"
VPC_ID="vpc-009f1a3a2fe900ee6"
SUBNET_GROUP_NAME="valkey-subnet-group"
SECURITY_GROUP_ID="sg-0c6bddd4d8942e446"

echo "Using Region: $REGION"

# =========================
# 1. CREATE SUBNET GROUP
# =========================

echo "Creating subnet group..."

aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name $SUBNET_GROUP_NAME \
    --cache-subnet-group-description "Subnet group for Valkey lab" \
    --subnet-ids subnet-0ff02d16d6718237c subnet-082e11a9a6bb0750f \
    --region $REGION
    
echo "Subnet group created"


echo "Creating Valkey Serverless cache..."

aws elasticache create-serverless-cache \
    --serverless-cache-name $CACHE_NAME \
    --engine valkey \
    --description "Valkey lab cache" \
    --security-group-ids $SECURITY_GROUP_ID \
    --subnet-ids subnet-0ff02d16d6718237c subnet-082e11a9a6bb0750f \
    --region $REGION

echo "Waiting for cache to become available..."

# =========================
# 3. GET ENDPOINT
# =========================

aws elasticache describe-serverless-caches \
    --serverless-cache-name $CACHE_NAME \
    --region $REGION \
    --query "ServerlessCaches[0].Endpoint.Address" \
    --output text

echo "Valkey setup completed!"