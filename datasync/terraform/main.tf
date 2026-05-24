provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "MyVPC" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    name="Terraform_VPC"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MyVPC.id
  tags = {
    name="Terraform_IGW"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.MyVPC
  cidr_block = "10.10.10.0/24"
  availability_zone = us-east-1a
  map_public_ip_on_launch = true
  tags = {
    name="Terraform_public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.MyVPC
  cidr_block = "10.10.11.0/24"
  availability_zone = us-east-1b
  tags = {
    name="Terraform_private_subnet"
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.MyVPC
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    name="Terraform_route_table"
  }
}
resource "aws_nat_gateway" "private_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.private_subnet
  tags = {
    name="Terraform_private_nat_gateway"
  }
  
}
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_nat_gateway_eip_association" "private_nat_association" {
  allocation_id = aws_eip.nat_eip.id
  nat_gateway_id = aws_nat_gateway.private_nat_gateway.id
}