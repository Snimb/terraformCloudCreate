resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "rds-master-credentials"
  description = "Master credentials for RDS instance"

  tags = {
    Name = "rds-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
