# Security Group for RDS (Allow traffic to PostgreSQL port from within the VPC)
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  # Allow inbound traffic on port 5432 for PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust based on your VPC CIDR range
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# RDS Subnet Group (Subnets in different Availability Zones)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "rds-subnet-group"
  }
}
