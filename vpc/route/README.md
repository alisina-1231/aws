## Creating Route Table
```sh
aws ec2 create-route-table \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text) \
--tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=RT-Gateway}]' \
--query 'RouteTable.RouteTableId' \
--output text
```

## Creating Route to Internet Gateway
```sh
aws ec2 create-route \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=RT-Gateway" --query 'RouteTables[0].RouteTableId' --output text) \  
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=IGW-Gateway" \
--query 'InternetGateways[0].InternetGatewayId' --output text)
```

## Associating Route Table with Subnet
```sh
aws ec2 associate-route-table \
--route-table-id $(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=RT-Gateway" --query 'RouteTables[0].RouteTableId' --output text) \
--subnet-id $(aws ec2 describe-subnets --filters "Name=tag:Name,Values=Subnet-Gateway" \
--query 'Subnets[0].SubnetId' --output text)
```