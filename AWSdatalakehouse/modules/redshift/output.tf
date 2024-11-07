output "redshift_cluster_endpoint" {
  value = aws_redshift_cluster.main.endpoint
}

output "redshift_cluster_id" {
  value = aws_redshift_cluster.main.cluster_identifier
}
