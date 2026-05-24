Amazon Web Services **AppSync** is a fully managed GraphQL API service from AWS that helps applications securely access, combine, and synchronize data from multiple sources in real time.

With AppSync, you can build APIs for:

* Web apps
* Mobile apps
* IoT applications
* Real-time dashboards
* Offline-first applications

It supports:

* **GraphQL APIs**
* Real-time subscriptions (WebSocket updates)
* Authentication with IAM, Cognito, API keys, OIDC
* Data sources like:

  * DynamoDB
  * Lambda
  * RDS
  * OpenSearch
  * HTTP APIs

---

# How AppSync Works

Basic flow:

```text
Client App
   |
GraphQL Query / Mutation / Subscription
   |
AWS AppSync
   |
Resolvers
   |
Data Source (DynamoDB/Lambda/etc.)
```

Example:

* Query → fetch data
* Mutation → update data
* Subscription → receive live updates automatically

---

# Simple Example

Suppose you create a Todo app.

## GraphQL Schema

```graphql
type Todo {
  id: ID!
  title: String!
}

type Query {
  getTodos: [Todo]
}

type Mutation {
  createTodo(id: ID!, title: String!): Todo
}
```

---

# Why Use AppSync

## Advantages

* No server management
* Real-time updates built in
* Offline sync support
* Scales automatically
* Easy integration with AWS services

---

# Main Components

| Component    | Purpose                  |
| ------------ | ------------------------ |
| GraphQL API  | Main API endpoint        |
| Schema       | Defines API structure    |
| Resolver     | Connects GraphQL to data |
| Data Source  | Backend storage/service  |
| Query        | Read data                |
| Mutation     | Write data               |
| Subscription | Real-time updates        |

---

# Let's Test AWS AppSync

We’ll create:

1. DynamoDB table
2. AppSync GraphQL API
3. Simple schema
4. Run queries and mutations

---

# Step 1 — Create DynamoDB Table

```bash
aws dynamodb create-table \
  --table-name TodoTable \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

---

# Step 2 — Create AppSync API

```bash
aws appsync create-graphql-api \
  --name TodoAPI \
  --authentication-type API_KEY
```

Save:

* `apiId`
* `uris.GRAPHQL`

---

# Step 3 — Create API Key

```bash
aws appsync create-api-key \
  --api-id YOUR_API_ID
```

Save the API key.

---

# Step 4 — Create GraphQL Schema

Create file:

```bash
nano schema.graphql
```

Add:

```graphql
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
```

Upload schema:

```bash
aws appsync start-schema-creation \
  --api-id YOUR_API_ID \
  --definition fileb://schema.graphql
```

---

# Step 5 — Create Data Source

Get DynamoDB table ARN:

```bash
aws dynamodb describe-table \
  --table-name TodoTable \
  --query "Table.TableArn" \
  --output text
```

Create IAM role first:

```bash
aws iam create-role \
  --role-name AppSyncDynamoRole \
  --assume-role-policy-document file://trust-policy.json
```

Trust policy:

```json
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
```

Attach policy:

```bash
aws iam attach-role-policy \
  --role-name AppSyncDynamoRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
```

Create datasource:

```bash
aws appsync create-data-source \
  --api-id YOUR_API_ID \
  --name TodoDS \
  --type AMAZON_DYNAMODB \
  --service-role-arn YOUR_ROLE_ARN \
  --dynamodb-config tableName=TodoTable,awsRegion=us-east-1
```

---

# Step 6 — Test Query in AWS Console

Open:

[AWS AppSync Console](https://console.aws.amazon.com/appsync/?utm_source=chatgpt.com)

Go to:

* Your API
* Queries tab

Run mutation:

```graphql
mutation {
  createTodo(id: "1", title: "Learn AppSync") {
    id
    title
  }
}
```

Run query:

```graphql
query {
  getTodo(id: "1") {
    id
    title
  }
}
```

---

# Real-Time Subscription Example

```graphql
subscription {
  onCreateTodo {
    id
    title
  }
}
```

Whenever a new todo is added, clients receive updates instantly.

---

# Common AppSync Use Cases

| Use Case       | Example        |
| -------------- | -------------- |
| Real-time chat | Messaging apps |
| Dashboard      | Live metrics   |
| Mobile backend | Android/iOS    |
| IoT            | Sensor updates |
| Offline sync   | Field apps     |

---

# AppSync vs API Gateway

| Feature          | AppSync     | API Gateway      |
| ---------------- | ----------- | ---------------- |
| API Type         | GraphQL     | REST/HTTP        |
| Real-time        | Built-in    | Extra setup      |
| Offline sync     | Yes         | No               |
| Flexible queries | Yes         | Limited          |
| Best For         | Modern apps | Traditional APIs |

---

# Recommended Next Labs

You can continue with:

1. Lambda resolver
2. Cognito authentication
3. Real-time subscriptions
4. React frontend
5. Amplify integration
6. Terraform/CloudFormation deployment

Official docs:

[AWS AppSync Documentation](https://docs.aws.amazon.com/appsync/?utm_source=chatgpt.com)
