resource "aws_glue_job" "etl_job" {
  name     = "data-etl-job"
  role_arn = aws_iam_role.glue_service_role.arn
  command {
    script_location = "s3://${module.s3.data_lake_bucket_name}/scripts/etl.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language" = "python"
  }
}

# Glue Catalog Database
resource "aws_glue_catalog_database" "data_lake" {
  name = "${var.environment}_data_lake_catalog"
}

# Glue Crawlers for various data sources
resource "aws_glue_crawler" "s3_crawler" {
  name         = "${var.environment}-s3-crawler"
  role         = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.data_lake.name

  s3_target {
    path = "s3://${module.s3.data_lake_bucket_name}/raw/"
  }

  schedule = "cron(0 * * * ? *)" # every hour

  tags = {
    Environment = var.environment
  }
}
