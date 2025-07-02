resource "aws_subnet" "public" {
  vpc_id                                        = var.vpc_id
  cidr_block                                    = var.cidr_block_subnet_pub
  availability_zone                             = var.availability_zone
  map_public_ip_on_launch                       = true

  tags = {
    Name                                        = "${var.vpc_name}-${var.availability_zone}-public-subnet"
    # "kubernetes.io/cluster/eks"                 = "shared"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "karpenter.sh/discovery"                    = var.cluster_name
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_subnet" "private" {
  vpc_id                                        = var.vpc_id
  cidr_block                                    = var.cidr_block_subnet_priv
  availability_zone                             = var.availability_zone
  map_public_ip_on_launch                       = false

  tags = {
    Name                                        = "${var.vpc_name}-${var.availability_zone}-private-subnet"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/cluster/eks"                 = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

resource "aws_eip" "eip" {
     domain = "vpc"

  tags = {
    Name      = "${var.vpc_name}-${var.availability_zone}-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id   = aws_eip.eip.id
  subnet_id       = aws_subnet.public.id

  depends_on      = [aws_subnet.public, aws_eip.eip]

  tags = {
    Name          = "${var.vpc_name}-${var.availability_zone}-nat_gw"
  }
}

resource "aws_route_table" "private" {
  vpc_id             = var.vpc_id

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat_gw.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gw.id
  # }

  tags = {
    Name              = "${var.vpc_name}-private-route_table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = var.public_route_table
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
