# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "data_science" {
  name               = "${var.environment}-data-science-notebook"
  instance_type      = var.instance_type
  role_arn           = aws_iam_role.sagemaker_execution_role.arn

  tags = {
    Environment = var.environment
  }
}

# IAM Role for SageMaker Execution
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.environment}-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policies to SageMaker Role
resource "aws_iam_role_policy_attachment" "sagemaker_policy_s3" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_policy_glue" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
