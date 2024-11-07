resource "aws_kendra_index" "confluence_index" {
  name               = "ConfluenceIndex"
  role_arn           = aws_iam_role.kendra_role.arn
  description        = "Index for Confluence data"

  edition = "DEVELOPER_EDITION"
}

resource "aws_kendra_datasource" "confluence_datasource" {
  index_id = aws_kendra_index.confluence_index.id
  name     = "ConfluenceDataSource"
  
  type = "CONFLUENCE"

  configuration {
    confluence_configuration {
      server_url = var.confluence_url
      secret_arn = aws_secretsmanager_secret.confluence_api_key.arn
    }
  }
}

resource "aws_kendra_index" "data_lake_index" {
  name      = "data-lake-index"
  role_arn  = aws_iam_role.kendra_role.arn

  description = "Kendra index for searching the data lake"
}

resource "aws_kendra_data_source" "s3_data_source" {
  index_id     = aws_kendra_index.data_lake_index.id
  name         = "S3DataLake"
  type         = "S3"
  configuration {
    s3_configuration {
      bucket_name = module.s3.data_lake_bucket_name
    }
  }
}

