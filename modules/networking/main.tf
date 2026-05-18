resource "aws_vpc" "vpc_bini" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"

  }
}

resource "aws_internet_gateway" "igw_bini" {
  vpc_id = aws_vpc.vpc_bini.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"

  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_bini.id

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"

  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_bini.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_bini.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.vpc_bini.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere - learning only."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # for learning only. In real projects, restrict SSH to your own IP.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-web-sg"
  }

}

resource "aws_subnet" "public_subnet_bini" {
  vpc_id                  = aws_vpc.vpc_bini.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-subnet"
  }
}
