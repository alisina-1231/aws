#!/bin/bash
# Create an ECR repository
aws ecr create-repository --repository-name docker/test --region us-east-1
# Authenticate Docker to AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 832014379019.dkr.ecr.us-east-1.amazonaws.com

# Build, tag, and push the Docker image to ECR
docker build -t docker/test .
docker tag docker/test:latest 832014379019.dkr.ecr.us-east-1.amazonaws.com/docker/test:latest
docker push 832014379019.dkr.ecr.us-east-1.amazonaws.com/docker/test:latest