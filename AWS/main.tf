# Create a new VPC
resource "aws_vpc" "free_tier_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "free-tier-vpc"
  }
}

# Create an internet gateway for the VPC
resource "aws_internet_gateway" "free_tier_gw" {
  vpc_id = aws_vpc.free_tier_vpc.id

  tags = {
    Name = "free-tier-gw"
  }
}

# Create a subnet
resource "aws_subnet" "free_tier_subnet" {
  vpc_id            = aws_vpc.free_tier_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"  # Change this to your preferred AZ

  tags = {
    Name = "free-tier-subnet"
  }
}

# Create a security group for the RDS instance
resource "aws_security_group" "free_tier_sg" {
  name        = "free-tier-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.free_tier_vpc.id

  ingress {
    from_port   = 5432  # PostgreSQL port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this to restrict access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "free-tier-sg"
  }
}

# Create a DB subnet group
resource "aws_db_subnet_group" "free_tier_db_subnet_group" {
  name       = "free-tier-db-subnet-group"
  subnet_ids = [aws_subnet.free_tier_subnet.id]

  tags = {
    Name = "free-tier-db-subnet-group"
  }
}

# Create an RDS instance
resource "aws_db_instance" "free_tier_postgresql_instance" {
  allocated_storage     = 20  # Minimum size in GB
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "14.2"  # Change to your preferred version
  instance_class        = "db.t3.micro"  # Free tier eligible instance
  db_name               = "new_db"
  username              = "postgres"
  password              = "P4ssw0rd!"
  parameter_group_name  = "default.postgres14"  # Adjust to your preferred parameter group
  db_subnet_group_name  = aws_db_subnet_group.free_tier_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.free_tier_sg.id]

  skip_final_snapshot   = true  # Set to false if you want to create a final snapshot when the DB is deleted

  tags = {
    Name = "free-tier-postgresql-instance"
  }
}

output "db_instance_endpoint" {
  value = aws_db_instance.free_tier_postgresql_instance.endpoint
}
