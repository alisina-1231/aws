## Create VPC Peering

```sh
# Create a VPC peering connection
aws ec2 create-vpc-peering-connection \
    --vpc-id vpc-0123456789abcdef0 \  # Replace with your VPC ID
    --peer-vpc-id vpc-abcdef0123456789 \  # Replace with the peer VPC ID
    --region us-west-2  # Replace with your desired region  
```

# Accept the VPC peering connection
```sh
aws ec2 accept-vpc-peering-connection \
    --vpc-peering-connection-id pcx-0123456789abcdef0 \  # Replace with your VPC peering connection ID
    --region us-west-2
```

## Create a route in the route table to direct traffic to the peered VPC
```sh
aws ec2 create-route \
    --route-table-id rtb-0123456789abcdef0 \  # Replace with your route table ID
    --destination-cidr-block 0.0.0.0/0 \
    --vpc-peering-connection-id pcx-0123456789abcdef0 \  # Replace with your VPC peering connection ID
    --region us-west-2  # Replace with your desired region
```