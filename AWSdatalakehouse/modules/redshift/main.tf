# Redshift Cluster
resource "aws_redshift_cluster" "main" {
  cluster_identifier           = "${var.environment}-redshift-cluster"
  node_type                    = var.node_type
  number_of_nodes              = var.number_of_nodes
  database_name                = var.database_name
  master_username              = var.master_username
  master_password              = var.master_password
  cluster_subnet_group_name    = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.redshift_sg.id]
  skip_final_snapshot          = true
  publicly_accessible          = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${var.environment}-redshift-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = var.environment
  }
}
