variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_2" {
  default = "10.0.2.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}
variable "image_id" {
  default = "ami-0236922087fa98b6e" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  
}