# Configure the AWS Provider
# Variables For ACK & SCK
variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC
resource "aws_vpc" "ansible_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ansible vpc"
  }
}

# Inrnet Gateway
resource "aws_internet_gateway" "ansible_igw" {
  vpc_id = aws_vpc.ansible_vpc.id

  tags = {
    Name = "ansible igw"
  }
}

# Public Subnet
resource "aws_subnet" "ansible_pub_sn" {
  vpc_id     = aws_vpc.ansible_vpc.id
  cidr_block = "10.0.0.0/24"
map_public_ip_on_launch = "true"
  tags = {
    Name = "ansible pub sn"
  }
}

# Private Subnet
resource "aws_subnet" "ansible_pvt_sn" {
  vpc_id     = aws_vpc.ansible_vpc.id
  cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = "false"
  tags = {
    Name = "ansible pvt sn"
  }
}
# public route table
resource "aws_route_table" "ansible_pbl_rt" {
  vpc_id = aws_vpc.ansible_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_igw.id
  }
tags = {
    Name = "ansible pbl rt"
  }
}

# private route table
resource "aws_route_table" "ansible_pvt_rt" {
  vpc_id = aws_vpc.ansible_vpc.id

tags = {
    Name = "ansible pvt rt"
  }
}
# public subnet association
resource "aws_route_table_association" "ansible_pbc_snc" {
  subnet_id      = aws_subnet.ansible_pub_sn.id
  route_table_id = aws_route_table.ansible_pbl_rt.id
}
#  private subnet association
resource "aws_route_table_association" "ansible_pvt_snc" {
  subnet_id      = aws_subnet.ansible_pvt_sn.id
  route_table_id = aws_route_table.ansible_pvt_rt.id
}

# security group
resource "aws_security_group" "ansible-all" {
  name        = "ansible-all"
  description = "Allow all traffic inbound traffic"
  vpc_id      = aws_vpc.ansible_vpc.id

  ingress {
    description = "all from WWW"
    from_port   = 0
    to_port     = 0
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
    Name = "all-ansible"
  }
}

# ansible master
resource "aws_instance" "ansible-master" {
  ami                    = "ami-0affd4508a5d2481b"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ansible_pub_sn.id
  vpc_security_group_ids = [aws_security_group.ansible-all.id]
  key_name               = "Linex8AM"
  private_ip = "10.0.0.10"
  user_data = file("install_ansible.sh")
  tags = {
    Name = "ansible-master"
  }
}


# ansible node 1
resource "aws_instance" "ansible-node1" {
  ami                    = "ami-0affd4508a5d2481b"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ansible_pub_sn.id
  vpc_security_group_ids = [aws_security_group.ansible-all.id]
  key_name               = "Linex8AM"
  private_ip = "10.0.0.20"
  tags = {
    Name = "ansible-node1"
  }
}


# ansible node 2
resource "aws_instance" "ansible-node2" {
  ami                    = "ami-0affd4508a5d2481b"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ansible_pub_sn.id
  vpc_security_group_ids = [aws_security_group.ansible-all.id]
  key_name               = "Linex8AM"
  private_ip = "10.0.0.21"
  tags = {
    Name = "ansible-node2"
  }
}