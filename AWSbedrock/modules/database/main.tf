# Create the PostgreSQL RDS instance
/*resource "aws_db_instance" "postgres" {
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = "postgres"
  engine_version       = "13.4"  # Specify the version of PostgreSQL
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az = true
  skip_final_snapshot  = true  # If you want to skip a final snapshot on deletion
  publicly_accessible  = false # Ensures the RDS instance is only accessible within the VPC

  tags = {
    Name = "my-postgres-db"
  }
}


resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-postgresql"
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name           = "postgres"
  master_username         = "postgres"
  master_password         = "Password123!"
  backup_retention_period = 7
  preferred_backup_window = "22:00-06:00"
}

*/
# Create the Multi-AZ PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  allocated_storage    = var.db_allocated_storage
  instance_class       = var.db_instance_class
  engine               = "postgres"
  engine_version       = "13.4"  # Specify the PostgreSQL version
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Enable Multi-AZ for high availability
  multi_az = true

  # Backup settings
  backup_retention_period = 7
  backup_window           = "03:00-04:00"  # When automated backups occur

  # Maintenance settings
  maintenance_window = "Mon:00:00-Mon:03:00"  # When maintenance may occur

  # Enable encryption
  storage_encrypted = true

  # Deletion protection
  deletion_protection = true

  # Publicly accessible
  publicly_accessible = false  # Keep the database private, accessible only within the VPC

  # Tags
  tags = {
    Name = "my-high-availability-postgres"
  }
}