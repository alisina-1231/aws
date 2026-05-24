#!/bin/bash

# ==========================================
# AWS DMS Migration
# PostgreSQL  --->  MySQL
# ==========================================

REGION="us-east-1"

# ==========================================
# Existing RDS Information
# ==========================================

POSTGRES_ENDPOINT="your-postgres-endpoint"
POSTGRES_PORT="5432"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="password"
POSTGRES_DB="postgres"

MYSQL_ENDPOINT="your-mysql-endpoint"
MYSQL_PORT="3306"
MYSQL_USER="admin"
MYSQL_PASSWORD="password"
MYSQL_DB="mysql"

# ==========================================
# Create DMS Replication Subnet Group
# ==========================================

echo "Creating DMS Replication Subnet Group..."

aws dms create-replication-subnet-group \
    --replication-subnet-group-identifier dms-subnet-group \
    --replication-subnet-group-description "DMS subnet group" \
    --subnet-ids subnet-xxxxxxxx \
    --region $REGION

# ==========================================
# Create DMS Replication Instance
# ==========================================

echo "Creating DMS Replication Instance..."

aws dms create-replication-instance \
    --replication-instance-identifier dms-test-instance \
    --replication-instance-class dms.t3.micro \
    --allocated-storage 20 \
    --publicly-accessible \
    --replication-subnet-group-identifier dms-subnet-group \
    --region $REGION

# ==========================================
# Wait for DMS Instance
# ==========================================

echo "Waiting for DMS Instance..."

aws dms wait replication-instance-available \
    --filters "Name=replication-instance-id,Values=dms-test-instance" \
    --region $REGION

# ==========================================
# Create PostgreSQL Source Endpoint
# ==========================================

echo "Creating PostgreSQL Source Endpoint..."

aws dms create-endpoint \
    --endpoint-identifier postgres-source \
    --endpoint-type source \
    --engine-name postgres \
    --server-name $POSTGRES_ENDPOINT \
    --port $POSTGRES_PORT \
    --username $POSTGRES_USER \
    --password $POSTGRES_PASSWORD \
    --database-name $POSTGRES_DB \
    --region $REGION

# ==========================================
# Create MySQL Target Endpoint
# ==========================================

echo "Creating MySQL Target Endpoint..."

aws dms create-endpoint \
    --endpoint-identifier mysql-target \
    --endpoint-type target \
    --engine-name mysql \
    --server-name $MYSQL_ENDPOINT \
    --port $MYSQL_PORT \
    --username $MYSQL_USER \
    --password $MYSQL_PASSWORD \
    --database-name $MYSQL_DB \
    --region $REGION

# ==========================================
# Get ARNs
# ==========================================

SOURCE_ARN=$(aws dms describe-endpoints \
    --filters "Name=endpoint-id,Values=postgres-source" \
    --query 'Endpoints[0].EndpointArn' \
    --output text \
    --region $REGION)

TARGET_ARN=$(aws dms describe-endpoints \
    --filters "Name=endpoint-id,Values=mysql-target" \
    --query 'Endpoints[0].EndpointArn' \
    --output text \
    --region $REGION)

REPLICATION_INSTANCE_ARN=$(aws dms describe-replication-instances \
    --filters "Name=replication-instance-id,Values=dms-test-instance" \
    --query 'ReplicationInstances[0].ReplicationInstanceArn' \
    --output text \
    --region $REGION)

# ==========================================
# Create Migration Task
# ==========================================

echo "Creating Migration Task..."

aws dms create-replication-task \
    --replication-task-identifier postgres-to-mysql-task \
    --source-endpoint-arn $SOURCE_ARN \
    --target-endpoint-arn $TARGET_ARN \
    --replication-instance-arn $REPLICATION_INSTANCE_ARN \
    --migration-type full-load \
    --table-mappings '{
        "rules": [
            {
                "rule-type": "selection",
                "rule-id": "1",
                "rule-name": "1",
                "object-locator": {
                    "schema-name": "%",
                    "table-name": "%"
                },
                "rule-action": "include"
            }
        ]
    }' \
    --region $REGION

# ==========================================
# Start Migration Task
# ==========================================

echo "Starting Migration..."

TASK_ARN=$(aws dms describe-replication-tasks \
    --filters "Name=replication-task-id,Values=postgres-to-mysql-task" \
    --query 'ReplicationTasks[0].ReplicationTaskArn' \
    --output text \
    --region $REGION)

aws dms start-replication-task \
    --replication-task-arn $TASK_ARN \
    --start-replication-task-type start-replication \
    --region $REGION

echo "Migration Started."