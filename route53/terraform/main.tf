terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==========================
# Route53 Hosted Zone
# ==========================

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "route53-test-zone"
  }
}

# ==========================
# Route53 DNS Record
# ==========================

resource "aws_route53_record" "test_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "test.${var.domain_name}"
  type    = "A"
  ttl     = 300

  records = [
    "8.8.8.8"
  ]
}