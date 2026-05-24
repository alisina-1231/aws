aws cloudformation create-stack \
  --stack-name opensearch-lab \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM

  aws cloudformation describe-stacks \
  --stack-name opensearch-lab \
  --query "Stacks[0].StackStatus"

  aws cloudformation describe-stacks \
  --stack-name opensearch-lab \
  --query "Stacks[0].Outputs"

  export ENDPOINT=https://search-my-opensearch-lab-ydnynwluvgj3ci5qkvb4xaas2i.us-east-1.es.amazonaws.com
  curl -X PUT "$ENDPOINT/employees"

  curl -X POST "$ENDPOINT/employees/_doc/1" \
-H "Content-Type: application/json" \
-d '
{
  "name": "Ali",
  "city": "Herat",
  "role": "Engineer"
}'

curl -X GET "$ENDPOINT/employees/_search?pretty"

curl -X GET "$ENDPOINT/employees/_search?pretty" \
-H "Content-Type: application/json" \
-d '
{
  "query": {
    "match": {
      "city": "Herat"
    }
  }
}'

aws cloudformation describe-stacks \
  --stack-name opensearch-lab \
  --query "Stacks[0].Outputs[?OutputKey=='DashboardURL'].OutputValue" \
  --output text