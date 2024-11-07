# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = data.aws_subnet_ids.private.ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

# Security group to allow access to RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.main.id
  name   = "${var.environment}-rds-sg"

  # Inbound rules to allow access from trusted resources
  ingress {
    from_port   = 5432  # For PostgreSQL, use 3306 for MySQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs  # IPs or CIDR blocks allowed to access RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# Provision an RDS instance
resource "aws_db_instance" "rds" {
  identifier              = "${var.environment}-rds-instance"
  allocated_storage       = var.allocated_storage
  engine                  = var.rds_engine          # e.g., "postgres" or "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class       # e.g., "db.t3.medium"
  db_name                 = var.db_name              # The database name to create inside the instance
  username                = var.db_username          # Master username
  password                = var.db_password          # Master password
  parameter_group_name    = aws_db_parameter_group.rds_pg.name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = var.multi_az             # Enable multi-AZ for redundancy
  storage_type            = var.storage_type         # gp2, io1
  backup_retention_period = var.backup_retention
  skip_final_snapshot     = false                    # Ensure final snapshot on deletion
  publicly_accessible     = false                    # Keep it private within the VPC
  storage_encrypted       = var.storage_encrypted
  kms_key_id              = var.kms_key_id           # Optional KMS key for encryption
  apply_immediately       = true

  tags = {
    Name        = "${var.environment}-rds-instance"
    Environment = var.environment
  }
}

# Optional: Parameter group for custom DB settings
resource "aws_db_parameter_group" "rds_pg" {
  name   = "${var.environment}-rds-parameter-group"
  family = var.rds_family # e.g., "postgres12" or "mysql5.7"

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = {
    Name        = "${var.environment}-rds-parameter-group"
    Environment = var.environment
  }
}
