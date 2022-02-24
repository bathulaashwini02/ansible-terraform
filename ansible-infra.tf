# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
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

