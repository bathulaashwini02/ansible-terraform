# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

# VPC
resource "aws_vpc" "ajio_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ajio vpc"
  }
}

# Inrnet Gateway
resource "aws_internet_gateway" "ajio_igw" {
  vpc_id = aws_vpc.ajio_vpc.id

  tags = {
    Name = "ajio igw"
  }
}

# Public Subnet
resource "aws_subnet" "ajio_pub_sn" {
  vpc_id     = aws_vpc.ajio_vpc.id
  cidr_block = "10.0.0.0/24"
map_public_ip_on_launch = "true"
  tags = {
    Name = "ajio pub sn"
  }
}

# Private Subnet
resource "aws_subnet" "ajio_pvt_sn" {
  vpc_id     = aws_vpc.ajio_vpc.id
  cidr_block = "10.0.1.0/24"
map_public_ip_on_launch = "false"
  tags = {
    Name = "ajio pvt sn"
  }
}
# public route table
resource "aws_route_table" "ajio_pbl_rt" {
  vpc_id = aws_vpc.ajio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ajio_igw.id
  }
tags = {
    Name = "ajio pbl rt"
  }
}

# private route table
resource "aws_route_table" "ajio_pvt_rt" {
  vpc_id = aws_vpc.ajio_vpc.id

tags = {
    Name = "ajio pvt rt"
  }
}
# public subnet association
resource "aws_route_table_association" "ajio_pbc_snc" {
  subnet_id      = aws_subnet.ajio_pub_sn.id
  route_table_id = aws_route_table.ajio_pbl_rt.id
}
#  private subnet association
resource "aws_route_table_association" "ajio_pvt_snc" {
  subnet_id      = aws_subnet.ajio_pvt_sn.id
  route_table_id = aws_route_table.ajio_pvt_rt.id
}

