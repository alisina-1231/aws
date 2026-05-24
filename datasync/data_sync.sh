#!/bin/bash

# Create Data Sync Job
az datasync job create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DATA_SYNC_JOB_NAME \
  --location $LOCATION \
  --source-endpoint $SOURCE_ENDPOINT_ID \
  --destination-endpoint $DESTINATION_ENDPOINT_ID \
  --sync-policy $SYNC_POLICY_ID \
  --trigger-schedule $TRIGGER_SCHEDULE_ID

# Start Data Sync Job
az datasync job start \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DATA_SYNC_JOB_NAME

# Monitor Data Sync Job
az datasync job show \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $DATA_SYNC_JOB_NAME \
    --query "properties.jobStatus" \
    --output tsv