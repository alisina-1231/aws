#!/bin/bash

set -e

# ====================================
# CONFIG
# ====================================

REGION="us-east-1"

CLUSTER_ID="memcache-lab"

SUBNET_GROUP_NAME="memcache-subnet-group"

# ====================================
# DELETE MEMCACHED CLUSTER
# ====================================

echo "Deleting Memcached cluster..."

aws elasticache delete-cache-cluster \
  --cache-cluster-id $CLUSTER_ID \
  --region $REGION

echo "Waiting for deletion..."

while true
do
    STATUS=$(aws elasticache describe-cache-clusters \
      --cache-cluster-id $CLUSTER_ID \
      --region $REGION \
      --query "CacheClusters[0].CacheClusterStatus" \
      --output text 2>/dev/null || echo "deleted")

    echo "Current status: $STATUS"

    if [[ "$STATUS" == "deleted" ]]; then
        break
    fi

    sleep 20
done

echo "Cluster deleted"

# ====================================
# DELETE SUBNET GROUP
# ====================================

echo "Deleting subnet group..."

aws elasticache delete-cache-subnet-group \
  --cache-subnet-group-name $SUBNET_GROUP_NAME \
  --region $REGION

echo "Subnet group deleted"

echo "Cleanup complete"