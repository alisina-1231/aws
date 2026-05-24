#!/bin/bash

set -e

# ====================================
# CONFIGURATION
# ====================================

REGION="us-east-1"

CACHE_NAME="redis-lab"

SUBNET_GROUP_NAME="redis-lab-subnet-group"

# ====================================
# DELETE REDIS CLUSTER
# ====================================

echo "Deleting Redis cluster..."

aws elasticache delete-cache-cluster \
    --cache-cluster-id $CACHE_NAME \
    --region $REGION

echo "Waiting for cluster deletion..."

while true
do
    STATUS=$(aws elasticache describe-cache-clusters \
        --cache-cluster-id $CACHE_NAME \
        --region $REGION \
        --query "CacheClusters[0].CacheClusterStatus" \
        --output text 2>/dev/null || echo "deleted")

    echo "Current status: $STATUS"

    if [[ "$STATUS" == "deleted" ]]; then
        break
    fi

    sleep 20
done

echo "Redis cluster deleted"

# ====================================
# DELETE SUBNET GROUP
# ====================================

echo "Deleting subnet group..."

aws elasticache delete-cache-subnet-group \
    --cache-subnet-group-name $SUBNET_GROUP_NAME \
    --region $REGION

echo "Subnet group deleted"

echo ""
echo "Cleanup completed"