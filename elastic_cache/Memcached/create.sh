#!/bin/bash

set -e

# ====================================
# CONFIG
# ====================================

REGION="us-east-1"

CLUSTER_ID="memcache-lab"

NODE_TYPE="cache.t3.micro"

NUM_NODES=1

ENGINE="memcached"

SUBNET_GROUP_NAME="memcache-subnet-group"

SECURITY_GROUP_ID="sg-xxxxxxxx"

SUBNET_1="subnet-xxxxxxxx"
SUBNET_2="subnet-yyyyyyyy"

# ====================================
# CREATE SUBNET GROUP
# ====================================

echo "Creating subnet group..."

aws elasticache create-cache-subnet-group \
  --cache-subnet-group-name $SUBNET_GROUP_NAME \
  --cache-subnet-group-description "Memcached subnet group" \
  --subnet-ids $SUBNET_1 $SUBNET_2 \
  --region $REGION

echo "Subnet group created"

# ====================================
# CREATE MEMCACHED CLUSTER
# ====================================

echo "Creating Memcached cluster..."

aws elasticache create-cache-cluster \
  --cache-cluster-id $CLUSTER_ID \
  --engine $ENGINE \
  --cache-node-type $NODE_TYPE \
  --num-cache-nodes $NUM_NODES \
  --security-group-ids $SECURITY_GROUP_ID \
  --cache-subnet-group-name $SUBNET_GROUP_NAME \
  --region $REGION

echo "Waiting for cluster..."

aws elasticache wait cache-cluster-available \
  --cache-cluster-id $CLUSTER_ID \
  --region $REGION

echo "Memcached cluster available"

# ====================================
# GET ENDPOINT
# ====================================

ENDPOINT=$(aws elasticache describe-cache-clusters \
  --cache-cluster-id $CLUSTER_ID \
  --show-cache-node-info \
  --region $REGION \
  --query "CacheClusters[0].ConfigurationEndpoint.Address" \
  --output text)

echo ""
echo "MEMCACHED ENDPOINT:"
echo "$ENDPOINT"