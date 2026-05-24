terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  
}
resource "aws_s3_bucket" "default" {
}

resource "aws_s3_object" "object" {
    bucket = aws_s3_bucket.default.id
    key = "file.txt"
    source = "file.txt" 
    etag = filemd5("file.txt") 
}

