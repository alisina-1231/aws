
########################################
# VPC
########################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-vpc"
  }
}

########################################
# Internet Gateway
########################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-igw"
  }
}

########################################
# Public Subnets
########################################

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

########################################
# Route Table
########################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

########################################
# Security Group
########################################

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

########################################
# User Data Script
########################################

locals {
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpda

              sudo systemctl enable httpd
              sudo systemctl start httpd

              sudo echo "<h1>Server: $(hostname)</h1>" > /var/www/html/index.html
              EOF
}

########################################
# Launch Template
########################################

resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template-"
  image_id      = var.image_id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG-Web-Server"
    }
  }
}

########################################
# Load Balancer
########################################

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.web_sg.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "terraform-alb"
  }
}

########################################
# Target Group
########################################

resource "aws_lb_target_group" "tg" {
  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

########################################
# Listener
########################################

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

########################################
# Auto Scaling Group
########################################

resource "aws_autoscaling_group" "asg" {
  name = "terraform-asg"

  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  target_group_arns = [
    aws_lb_target_group.tg.arn
  ]

  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-asg-instance"
    propagate_at_launch = true
  }
}