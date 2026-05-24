#!/bin/bash

set -e

# ====================================
# CONFIGURATION
# ====================================

REGION="us-east-1"

CACHE_NAME="redis-lab"

ENGINE="redis"

CACHE_NODE_TYPE="cache.t3.micro"

NUM_NODES=1

SUBNET_GROUP_NAME="redis-lab-subnet-group"

SECURITY_GROUP_ID="sg-xxxxxxxx"

SUBNET_1="subnet-xxxxxxxx"
SUBNET_2="subnet-yyyyyyyy"

# ====================================
# CREATE SUBNET GROUP
# ====================================

echo "Creating subnet group..."

aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name $SUBNET_GROUP_NAME \
    --cache-subnet-group-description "Redis lab subnet group" \
    --subnet-ids $SUBNET_1 $SUBNET_2 \
    --region $REGION

echo "Subnet group created"

# ====================================
# CREATE REDIS CLUSTER
# ====================================

echo "Creating Redis cluster..."

aws elasticache create-cache-cluster \
    --cache-cluster-id $CACHE_NAME \
    --engine $ENGINE \
    --cache-node-type $CACHE_NODE_TYPE \
    --num-cache-nodes $NUM_NODES \
    --cache-subnet-group-name $SUBNET_GROUP_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --region $REGION

echo "Waiting for Redis cluster..."

aws elasticache wait cache-cluster-available \
    --cache-cluster-id $CACHE_NAME \
    --region $REGION

echo "Redis cluster available"

# ====================================
# GET REDIS ENDPOINT
# ====================================

ENDPOINT=$(aws elasticache describe-cache-clusters \
    --cache-cluster-id $CACHE_NAME \
    --show-cache-node-info \
    --region $REGION \
    --query "CacheClusters[0].CacheNodes[0].Endpoint.Address" \
    --output text)

echo ""
echo "REDIS ENDPOINT:"
echo "$ENDPOINT"
echo ""
echo "Test with:"
echo "redis-cli -h $ENDPOINT -p 6379"