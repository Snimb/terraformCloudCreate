data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdaFunction"
  output_path = "${path.module}/lambdaFunction/bedrock-lambda.zip"
}


# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda to interact with VPC endpoints
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-vpc-endpoint-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

# Lambda function within private subnet
resource "aws_lambda_function" "bedrock_lambda" {
  function_name    = "BedrockTestLambdaFunction"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  filename         = "lambdaFunction/bedrock-lambda.zip" # Add the path to your zipped Lambda function here
  # source_code_hash = filebase64sha256("${path.module}/lambdaFunction/bedrock-lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.bedrock_sg.id]
  }
}

# IAM policy for Bedrock API access via VPC Endpoint
resource "aws_iam_role_policy" "lambda_bedrock_policy" {
  name = "lambda-bedrock-access-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:InvokeModel"
        ]
        Resource = "*"
        Condition = {
          "ForAnyValue:StringEquals" = {
            "aws:sourceVpce" = [aws_vpc_endpoint.bedrock_endpoint.id]
          }
        }
      }
    ]
  })
}
