# Textract IAM Role
resource "aws_iam_role" "textract_role" {
  name = "${var.environment}-textract-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "textract.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Permissions to Textract Role
resource "aws_iam_role_policy_attachment" "textract_policy_s3" {
  role       = aws_iam_role.textract_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_lambda_function" "textract_trigger_lambda" {
  function_name    = "textract-trigger-lambda"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.textract_role.arn
  s3_bucket        = var.lambda_code_s3_bucket
  s3_key           = var.lambda_code_s3_key
  source_code_hash = filebase64sha256(var.lambda_code_s3_key)

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.data_lake.bucket
    }
  }

  tags = {
    Environment = var.environment
  }
}
