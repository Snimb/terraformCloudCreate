# Output the RDS instance endpoint (useful for application connections)
output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.rds.endpoint
}

# Output the RDS instance identifier
output "rds_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.rds.id
}

# Output the RDS security group ID (useful if other resources need to reference this SG)
output "rds_security_group_id" {
  description = "The security group ID associated with the RDS instance."
  value       = aws_security_group.rds_sg.id
}

# Output the RDS subnet group name (useful for other resources in the same VPC)
output "rds_subnet_group_name" {
  description = "The name of the RDS DB Subnet Group."
  value       = aws_db_subnet_group.rds_subnet_group.name
}
