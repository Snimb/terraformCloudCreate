# Output the secret ARN (optional, but useful to know the secret's unique identifier)
output "aws_secrets_arn" {
  value       = aws_secretsmanager_secret.aws_credentials_secret.arn
  description = "The ARN of the AWS Secrets Manager secret."
}