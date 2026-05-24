# AWS VPC and EC2 Automation Script

## Overview

This Bash script automates the creation of a basic AWS networking environment and launches an EC2 instance using the AWS CLI.

The script performs the following tasks:

1. Creates a VPC
2. Creates a public subnet
3. Enables automatic public IP assignment
4. Creates and attaches an Internet Gateway
5. Creates a Route Table and internet route
6. Associates the Route Table with the subnet
7. Creates a Security Group
8. Opens SSH access (Port 22)
9. Creates an EC2 Key Pair
10. Launches an EC2 instance
11. Waits for the instance to start
12. Retrieves the public IP address
13. Connects to the instance using SSH

---

# Architecture

```text id="e8l40w"
Internet
    |
Internet Gateway
    |
Route Table
    |
Public Subnet (192.168.1.0/24)
    |
EC2 Instance (Ubuntu)
```

---

# Prerequisites

Before running the script, ensure you have:

* An AWS account
* AWS CLI installed and configured
* `jq` installed
* Proper IAM permissions for:

  * VPC
  * EC2
  * Security Groups
  * Key Pairs
  * Route Tables

---

# Install Requirements

## Install AWS CLI

### Ubuntu

```bash id="vqyr3g"
sudo apt update
sudo apt install awscli -y
```

Verify installation:

```bash id="6h5v1k"
aws --version
```

---

## Install jq

### Ubuntu

```bash id="qq4l40"
sudo apt install jq -y
```

Verify installation:

```bash id="ot9t3y"
jq --version
```

---

# Configure AWS CLI

Run:

```bash id="j3w6ly"
aws configure
```

Enter:

* AWS Access Key ID
* AWS Secret Access Key
* Default region (`us-east-1`)
* Output format (`json`)

---

# Usage

## 1. Save the Script

Save the script as:

```bash id="6r0t2v"
deploy.sh
```

---

## 2. Make it Executable

```bash id="t6zpq9"
chmod +x deploy.sh
```

---

## 3. Run the Script

```bash id="yaz3ct"
./create-vpc-ec2.sh
```

---

# What the Script Creates

| Resource          | Details               |
| ----------------- | --------------------- |
| VPC               | `192.168.0.0/16`      |
| Public Subnet     | `192.168.1.0/24`      |
| Availability Zone | `us-east-1a`          |
| Internet Gateway  | Attached to VPC       |
| Route Table       | Public internet route |
| Security Group    | SSH access enabled    |
| Key Pair          | `my-key-pair.pem`     |
| EC2 Instance      | `t3.micro` Ubuntu     |

---

# SSH Access

After the instance launches, connect using:

```bash id="lm8lww"
ssh -i my-key-pair.pem ubuntu@<PUBLIC_IP>
```

Example:

```bash id="ye2rvg"
ssh -i my-key-pair.pem ubuntu@54.123.45.67
```

---

# Security Warning

The script allows SSH access from anywhere:

```text id="jlwmv8"
0.0.0.0/0
```

For production environments, restrict SSH access to your IP address:

```bash id="sk0v7o"
--cidr YOUR_PUBLIC_IP/32
```

---

# Cleanup Resources

To avoid AWS charges, delete resources after testing:

* EC2 Instance
* Security Group
* Route Table
* Internet Gateway
* Subnet
* VPC
* Key Pair

---

# Notes

* The script uses Ubuntu AMI:

  ```text id="7gaj62"
  ami-0d77bccb32adafa57
  ```
* Region:

  ```text id="i2z4jh"
  us-east-1
  ```
* Instance type:

  ```text id="zq2gsq"
  t3.micro
  ```

---

# Example Output

```text id="ghcxxs"
Step 1: Create VPC
VPC ID: vpc-0123456789abcdef0

Step 2: Create Subnet
Subnet ID: subnet-0123456789abcdef0

Step 10: Create EC2 Instance
EC2 Instance is running

Public IP Address: 54.123.45.67
```

---

# License

This project is for learning and educational purposes.
