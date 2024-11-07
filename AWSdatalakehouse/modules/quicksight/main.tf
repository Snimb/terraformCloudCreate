# IAM Role for QuickSight Access
resource "aws_iam_role" "quicksight_access_role" {
  name = "${var.environment}-quicksight-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Permissions to QuickSight Role
resource "aws_iam_role_policy_attachment" "quicksight_policy" {
  role       = aws_iam_role.quicksight_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonQuickSightAccess"
}
