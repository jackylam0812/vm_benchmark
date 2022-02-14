# aws-variables.tf | Variables for the AWS module

# AWS authentication variables
variable "aws_access_key" {
    default = "xxx" # please change to your aws access key 
}

variable "aws_secret_key" {
    default = "xxx" # please change to your aws secret key 
}

# AWS Region
variable "aws_region" {
  default = "us-east-1"
}

# AWS AZ
variable "aws_az" {
  default = "us-east-1c"
}

# VPC Variable  
variable "aws_vpc_cidr" {
  default = "10.10.0.0/16"
}

# Subnet Variable
variable "aws_subnet_cidr" {
  default = "10.10.1.0/24"
}

variable "aws_key_pair" {
  default = "xxx"  # please change to your ec2 key pair
}
