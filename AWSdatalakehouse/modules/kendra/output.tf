output "kendra_confluence_index_id" {
  value = aws_kendra_index.confluence_index.id
}

output "kendra_datasource_id" {
  value = aws_kendra_data_source.confluence_datasource.id
}
