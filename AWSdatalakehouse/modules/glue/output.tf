output "glue_catalog_database_name" {
  value = aws_glue_catalog_database.data_lake.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.s3_crawler.name
}
