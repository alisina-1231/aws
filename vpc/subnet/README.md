## Creating Subnet
```sh
aws ec2 create-subnet \
--vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=VPC-Gateway" --query 'Vpcs[0].VpcId' --output text) \
--cidr-block 10.10.1.0/24 \
--query 'Subnet.SubnetId' \
--output text
```