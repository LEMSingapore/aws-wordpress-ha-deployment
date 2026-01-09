# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.iam_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw-${var.iam_name}"
  }
}

# Subnet 1 - Public (70 hosts requirement)
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs.subnet1
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
    Type = "Public"
  }
}

# Subnet 2 - Public (30 hosts requirement)
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs.subnet2
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-2"
    Type = "Public"
  }
}

# Subnet 3 - Public (10 hosts requirement)
resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs.subnet3
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-3"
    Type = "Public"
  }
}

# Subnet 4 - Private (10 hosts requirement)
resource "aws_subnet" "subnet4" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs.subnet4
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-4"
    Type = "Private"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "eip-nat-${var.iam_name}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP for Webserver
resource "aws_eip" "webserver" {
  domain = "vpc"

  tags = {
    Name = "eip-webserver-${var.iam_name}"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway (for private subnet internet access)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "natg-${var.iam_name}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rtb-${var.iam_name}-public"
  }
}

# Private Route Table (routes through NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "rtb-${var.iam_name}-private"
  }
}

# Route Table Associations
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.private.id
}
