#!/bin/bash

DOMAIN=$1
IP=$2

if [ -z "$DOMAIN" ] || [ -z "$IP" ]; then
    echo "Usage: $0 domain-name ip-address"
    exit 1
fi

echo "Creating hosted zone..."

ZONE_ID=$(aws route53 create-hosted-zone \
  --name $DOMAIN \
  --caller-reference $(date +%s) \
  --query 'HostedZone.Id' \
  --output text | cut -d'/' -f3)

echo "Hosted Zone ID: $ZONE_ID"

echo "Creating DNS record..."

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch file://change.json

echo "Creating health check..."

aws route53 create-health-check \
  --caller-reference $(date +%s) \
  --health-check-config "{
      \"IPAddress\": \"$IP\",
      \"Port\": 80,
      \"Type\": \"HTTP\",
      \"ResourcePath\": \"/\",
      \"RequestInterval\": 30,
      \"FailureThreshold\": 3
  }"

echo "Done."