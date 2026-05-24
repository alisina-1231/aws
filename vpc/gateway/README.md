## Create Internet Gateway
```sh
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=IGW-Gateway}]' \
    --query 'InternetGateway.InternetGatewayId' \
    --output text   
```


## Attaching Internet Gateway to VPC
```sh
aws ec2 attach-internet-gateway \
--internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=IGW-Gateway" \
--query 'InternetGateways[0].InternetGatewayId' --output text) \
--vpc-id $(aws ec2 describe-vpcs \
--filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text)
```
