#!/bin/bash

set -e

# =========================
# CONFIG
# =========================

REGION="us-east-1"

CACHE_NAME="valkey-lab"
SUBNET_GROUP_NAME="valkey-subnet-group"

echo "Starting ElastiCache Valkey cleanup..."

# =========================
# DELETE SERVERLESS CACHE
# =========================

echo "Deleting serverless cache: $CACHE_NAME"

aws elasticache delete-serverless-cache \
    --serverless-cache-name $CACHE_NAME \
    --region $REGION

echo "Waiting for cache deletion..."

while true; do
    STATUS=$(aws elasticache describe-serverless-caches \
        --serverless-cache-name $CACHE_NAME \
        --region $REGION \
        --query "ServerlessCaches[0].Status" \
        --output text 2>/dev/null || echo "DELETED")

    echo "Current status: $STATUS"

    if [[ "$STATUS" == "DELETED" ]] || [[ "$STATUS" == "None" ]]; then
        break
    fi

    sleep 20
done

echo "Cache deleted"

# =========================
# DELETE SUBNET GROUP
# =========================

echo "Deleting subnet group: $SUBNET_GROUP_NAME"

aws elasticache delete-cache-subnet-group \
    --cache-subnet-group-name $SUBNET_GROUP_NAME \
    --region $REGION

echo "Subnet group deleted"

echo "Cleanup completed successfully"