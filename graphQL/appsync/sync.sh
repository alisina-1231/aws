#!/bin/bash

set -e

# =========================
# CONFIG
# =========================
REGION="us-east-1"
API_NAME="TodoAPI"
TABLE_NAME="TodoTable"
ROLE_NAME="AppSyncDynamoRole"
DATASOURCE_NAME="TodoDS"

echo "===================================="
echo "1. Creating DynamoDB Table"
echo "===================================="

aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

aws dynamodb wait table-exists \
  --table-name $TABLE_NAME \
  --region $REGION

echo "Table created."

# =========================
# CREATE APP SYNC API
# =========================
echo "===================================="
echo "2. Creating AppSync API"
echo "===================================="

API_OUTPUT=$(aws appsync create-graphql-api \
  --name $API_NAME \
  --authentication-type API_KEY \
  --region $REGION)

API_ID=$(echo $API_OUTPUT | jq -r '.graphqlApi.apiId')
GRAPHQL_URL=$(echo $API_OUTPUT | jq -r '.graphqlApi.uris.GRAPHQL')

echo "API ID: $API_ID"

# =========================
# CREATE API KEY
# =========================
echo "===================================="
echo "3. Creating API Key"
echo "===================================="

API_KEY=$(aws appsync create-api-key \
  --api-id $API_ID \
  --region $REGION \
  | jq -r '.apiKey.id')

echo "API Key created."

# =========================
# CREATE SCHEMA
# =========================
echo "===================================="
echo "4. Creating Schema"
echo "===================================="

cat > schema.graphql <<EOF
type Todo {
  id: ID!
  title: String!
}

type Query {
  getTodo(id: ID!): Todo
}

type Mutation {
  createTodo(id: ID!, title: String!): Todo
}

schema {
  query: Query
  mutation: Mutation
}
EOF

aws appsync start-schema-creation \
  --api-id $API_ID \
  --definition fileb://schema.graphql \
  --region $REGION

# =========================
# CREATE IAM ROLE
# =========================
echo "===================================="
echo "5. Creating IAM Role"
echo "===================================="

cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess

sleep 10

ROLE_ARN=$(aws iam get-role \
  --role-name $ROLE_NAME \
  | jq -r '.Role.Arn')

# =========================
# CREATE DATA SOURCE
# =========================
echo "===================================="
echo "6. Creating Data Source"
echo "===================================="

aws appsync create-data-source \
  --api-id $API_ID \
  --name $DATASOURCE_NAME \
  --type AMAZON_DYNAMODB \
  --service-role-arn $ROLE_ARN \
  --dynamodb-config tableName=$TABLE_NAME,awsRegion=$REGION

# =========================
# CREATE RESOLVERS
# =========================
echo "===================================="
echo "7. Creating Resolvers"
echo "===================================="

# ---- createTodo resolver ----
cat > createTodo-request.vtl <<EOF
{
  "version": "2018-05-29",
  "operation": "PutItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
  },
  "attributeValues": {
    "title": $util.dynamodb.toDynamoDBJson($ctx.args.title)
  }
}
EOF

cat > createTodo-response.vtl <<EOF
$util.toJson($ctx.result)
EOF

aws appsync create-resolver \
  --api-id $API_ID \
  --type-name Mutation \
  --field-name createTodo \
  --data-source-name $DATASOURCE_NAME \
  --request-mapping-template file://createTodo-request.vtl \
  --response-mapping-template file://createTodo-response.vtl

# ---- getTodo resolver ----
cat > getTodo-request.vtl <<EOF
{
  "version": "2018-05-29",
  "operation": "GetItem",
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
  }
}
EOF

cat > getTodo-response.vtl <<EOF
$util.toJson($ctx.result)
EOF

aws appsync create-resolver \
  --api-id $API_ID \
  --type-name Query \
  --field-name getTodo \
  --data-source-name $DATASOURCE_NAME \
  --request-mapping-template file://getTodo-request.vtl \
  --response-mapping-template file://getTodo-response.vtl

# =========================
# DONE
# =========================
echo "===================================="
echo "DEPLOYMENT COMPLETE"
echo "===================================="

echo "API ID: $API_ID"
echo "GRAPHQL URL: $GRAPHQL_URL"
echo "API KEY: $API_KEY"

echo ""
echo "Test Mutation:"
echo "mutation { createTodo(id:\"1\", title:\"hello\") { id title } }"
echo ""
echo "Test Query:"
echo "{ getTodo(id:\"1\") { id title } }"