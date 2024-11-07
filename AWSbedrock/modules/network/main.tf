data "aws_availability_zones" "available" {
  state = "available"
}

# Define the VPC
resource "aws_vpc" "bedrock_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "bedrock-vpc"
  }
}

# Create the first private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.bedrock_vpc.id
  cidr_block              = var.private_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "Bedrock Private Subnet 1"
  }
}

# Create the second private subnet
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.bedrock_vpc.id
  cidr_block              = var.private_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "Bedrock Private Subnet 2"
  }
}

# Create a NAT Gateway for the private subnet
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


# Create a Route Table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.bedrock_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private_route_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a VPC Endpoint for Amazon Bedrock using PrivateLink
resource "aws_vpc_endpoint" "bedrock_endpoint" {
  vpc_id            = aws_vpc.bedrock_vpc.id
  service_name      = "com.amazonaws.${var.bedrock_location}.bedrock-runtime"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet_1.id]

  security_group_ids = [aws_security_group.bedrock_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "bedrock-vpc-endpoint"
  }
}

# Create a Security Group for the Bedrock VPC
resource "aws_security_group" "bedrock_sg" {
  vpc_id = aws_vpc.bedrock_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust based on your VPC's CIDR range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bedrock-sg"
  }
}

