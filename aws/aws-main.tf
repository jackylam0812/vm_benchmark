# aws-main.tf | Define AWS Provider, VPC, Subnet, Routes, Security Groups, EC2 Instance

# Initialize the AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

# Create the VPC
resource "aws_vpc" "aws-vpc" {
  cidr_block = var.aws_vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-network-benchmark-vpc-${random_string.random.result}"
  }
}

# Define the subnet
resource "aws_subnet" "aws-subnet" {
  vpc_id = aws_vpc.aws-vpc.id
  cidr_block = var.aws_subnet_cidr
  availability_zone = var.aws_az
  tags = {
    Name = "terraform-network-benchmark-subnet-${random_string.random.result}"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "aws-gw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "terraform-network-benchmark-igw-${random_string.random.result}"
  }
}

# Define the route table to internet
resource "aws_route_table" "aws-route-table" {
  vpc_id = aws_vpc.aws-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-gw.id
  }
  tags = {
    Name = "terraform-network-benchmark-route-table-${random_string.random.result}"
  }
}

# Assign the public route table to the subnet
resource "aws_route_table_association" "aws-route-table-association" {
  subnet_id = aws_subnet.aws-subnet.id
  route_table_id = aws_route_table.aws-route-table.id
}

# Define the security group for HTTP web server
resource "aws_security_group" "aws-sg" {
  name = "terraform-network-benchmark-sg-${random_string.random.result}"
  description = "Allow incoming HTTP connections"
  vpc_id = aws_vpc.aws-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-network-benchmark-sg-${random_string.random.result}"
  }
}

# Get latest Ubuntu 18.04 AMI
data "aws_ami" "ubuntu-18_04-x86" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu-18_04-arm" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-arm64-server-*"]
  }
  
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# ---- VM01 ----
resource "aws_instance" "benchmark-ec2-01" {
  ami = data.aws_ami.ubuntu-18_04-x86.id
  instance_type = "m6i.xlarge"
  subnet_id = aws_subnet.aws-subnet.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  associate_public_ip_address = true
  source_dest_check = false
  key_name = var.aws_key_pair
  user_data = local.startup_script
  tags = {
    Name = "terraform-network-benchmark-instance-${random_string.random.result}"
  }
  root_block_device{
      volume_size = 50
      volume_type = "gp3"
    }
}

# #---- VM02 ----
# resource "aws_instance" "benchmark-ec2-02" {
#   ami = data.aws_ami.ubuntu-18_04-x86.id
#   instance_type = "m6i.8xlarge"
#   subnet_id = aws_subnet.aws-subnet.id
#   vpc_security_group_ids = [aws_security_group.aws-sg.id]
#   associate_public_ip_address = true
#   source_dest_check = false
#   key_name = var.aws_key_pair
#   user_data = local.startup_script
#   tags = {
#     Name = "terraform-network-benchmark-instance-${random_string.random.result}"
#   }
#   root_block_device{
#       volume_size = 50
#       volume_type = "gp3"
#     }
# }