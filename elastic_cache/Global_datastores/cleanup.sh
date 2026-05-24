#!/bin/bash

set -e

PRIMARY_REGION="us-east-1"
SECONDARY_REGION="us-west-2"

PRIMARY_CLUSTER="redis-primary"
SECONDARY_CLUSTER="redis-secondary"

GLOBAL_ID="global-redis-lab"

echo "Deleting secondary cluster..."

aws elasticache delete-replication-group \
  --replication-group-id $SECONDARY_CLUSTER \
  --region $SECONDARY_REGION

aws elasticache wait replication-group-deleted \
  --replication-group-id $SECONDARY_CLUSTER \
  --region $SECONDARY_REGION

echo "Deleting global datastore..."

aws elasticache delete-global-replication-group \
  --global-replication-group-id $GLOBAL_ID \
  --region $PRIMARY_REGION

echo "Deleting primary cluster..."

aws elasticache delete-replication-group \
  --replication-group-id $PRIMARY_CLUSTER \
  --region $PRIMARY_REGION

aws elasticache wait replication-group-deleted \
  --replication-group-id $PRIMARY_CLUSTER \
  --region $PRIMARY_REGION

echo "Cleanup completed"