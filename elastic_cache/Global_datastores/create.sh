#!/bin/bash

set -e

# =========================
# CONFIG
# =========================

PRIMARY_REGION="us-east-1"
SECONDARY_REGION="us-west-2"

PRIMARY_CLUSTER="redis-primary"
SECONDARY_CLUSTER="redis-secondary"

GLOBAL_ID="global-redis-lab"

NODE_TYPE="cache.t3.micro"
ENGINE="redis"

SUBNET_GROUP_PRIMARY="redis-subnet-primary"
SUBNET_GROUP_SECONDARY="redis-subnet-secondary"

SG_PRIMARY="sg-xxxxxxxx"
SG_SECONDARY="sg-yyyyyyyy"

SUBNET_1="subnet-aaa"
SUBNET_2="subnet-bbb"

# =========================
# STEP 1: CREATE PRIMARY REPLICA
# =========================

echo "Creating PRIMARY Redis cluster..."

aws elasticache create-replication-group \
  --replication-group-id $PRIMARY_CLUSTER \
  --replication-group-description "Primary Redis" \
  --engine $ENGINE \
  --cache-node-type $NODE_TYPE \
  --num-node-groups 1 \
  --replicas-per-node-group 1 \
  --automatic-failover-enabled \
  --cache-subnet-group-name $SUBNET_GROUP_PRIMARY \
  --security-group-ids $SG_PRIMARY \
  --region $PRIMARY_REGION

echo "Waiting for primary..."

aws elasticache wait replication-group-available \
  --replication-group-id $PRIMARY_CLUSTER \
  --region $PRIMARY_REGION

# =========================
# STEP 2: CREATE GLOBAL DATASTORE
# =========================

echo "Creating Global Datastore..."

aws elasticache create-global-replication-group \
  --global-replication-group-id $GLOBAL_ID \
  --primary-replication-group-id $PRIMARY_CLUSTER \
  --region $PRIMARY_REGION

# =========================
# STEP 3: ADD SECONDARY REGION
# =========================

echo "Adding secondary region..."

aws elasticache create-replication-group \
  --replication-group-id $SECONDARY_CLUSTER \
  --replication-group-description "Secondary Redis" \
  --global-replication-group-id $GLOBAL_ID \
  --region $SECONDARY_REGION \
  --cache-node-type $NODE_TYPE \
  --cache-subnet-group-name $SUBNET_GROUP_SECONDARY \
  --security-group-ids $SG_SECONDARY

echo "Waiting secondary..."

aws elasticache wait replication-group-available \
  --replication-group-id $SECONDARY_CLUSTER \
  --region $SECONDARY_REGION

echo "GLOBAL DATASTORE CREATED"