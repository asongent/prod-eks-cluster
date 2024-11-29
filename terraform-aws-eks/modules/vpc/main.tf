resource "aws_vpc" "soc_vpc" {
  cidr_block       = var.cidr_block_vpc
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  } 
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.soc_vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.soc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route_table"
  }
}
