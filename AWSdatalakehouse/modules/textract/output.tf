output "textract_role_arn" {
  value = aws_iam_role.textract_role.arn
}

output "textract_trigger_lambda_name" {
  value = aws_lambda_function.textract_trigger_lambda.function_name
}
