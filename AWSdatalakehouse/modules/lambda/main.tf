resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Lambda Execution Role"
  }
}

resource "aws_iam_policy_attachment" "lambda_execution_policy" {
  name       = "lambda-execution-policy-attachment"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "fetch_sharepoint_data" {
  function_name = "fetch_sharepoint_data"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda/fetch_sharepoint.zip")

  environment {
    variables = {
      SHAREPOINT_API_KEY = var.sharepoint_api_key
      S3_BUCKET          = aws_s3_bucket.data_lake_raw.bucket
    }
  }
}

resource "aws_lambda_function" "confluence_fetch" {
  filename         = "confluence_fetch.zip"
  function_name    = "fetch_confluence_data"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("confluence_fetch.zip")

  environment {
    variables = {
      CONFLUENCE_API_KEY = var.confluence_api_key
      S3_BUCKET          = aws_s3_bucket.data_lake_raw.bucket
    }
  }
}

resource "aws_lambda_function" "data_ingestion" {
  function_name = "data-ingestion-function"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      RDS_ENDPOINT   = module.rds.rds_endpoint
      S3_BUCKET      = aws_s3_bucket.data_lake_raw.bucket
    }
  }

  s3_bucket = var.lambda_code_s3_bucket
  s3_key    = var.lambda_code_s3_key

  tags = {
    Name = "data-ingestion-lambda"
  }
}

resource "aws_cloudwatch_event_rule" "data_ingestion_schedule" {
  name        = "data-ingestion-schedule"
  description = "Trigger Lambda every hour to ingest data"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.data_ingestion_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.data_ingestion.arn
}
