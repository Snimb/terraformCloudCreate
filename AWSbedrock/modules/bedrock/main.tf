data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

# Create a S3 bucket
resource "aws_s3_bucket" "model_training" {
  bucket        = "model-training-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# Create a policy document to allow Bedrock to assume the role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:model-customization-job/*"]
    }
  }
}

# Create a policy document to allow Bedrock to access the S3 bucket
data "aws_iam_policy_document" "bedrock_custom_policy" {
  statement {
    sid       = "AllowS3Access"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.model_training.arn, "${aws_s3_bucket.model_training.arn}/*"]
  }
}

resource "aws_iam_policy" "bedrock_custom_policy" {
  name_prefix = "BedrockCM-"
  description = "Policy for Bedrock Custom Models customization jobs"
  policy      = data.aws_iam_policy_document.bedrock_custom_policy.json
}

# Create a role for Bedrock to assume
resource "aws_iam_role" "bedrock_custom_role" {
  name_prefix = "BedrockCM-"
  description = "Role for Bedrock Custom Models customization jobs"

  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.bedrock_custom_policy.arn]
}

resource "terraform_data" "training_data_fine_tune_v1" {
  input = "dialogsum-train-finetune.jsonl"

  provisioner "local-exec" {
    command = "python dialogsum-dataset-finetune.py"
  }
}

resource "aws_s3_object" "v1_training_fine_tune" {
  bucket = aws_s3_bucket.model_training.id
  key    = "training_data_v1/${terraform_data.training_data_fine_tune_v1.output}"
  source = terraform_data.training_data_fine_tune_v1.output
}

data "aws_bedrock_foundation_model" "cohere_command_light_text_v14" {
  model_id = "cohere.command-light-text-v14:7:4k"
}

resource "aws_bedrock_custom_model" "cm_cohere_v1" {
  custom_model_name     = "cm_cohere_v001"
  job_name              = "cm.command-light-text-v14.v001"
  base_model_identifier = data.aws_bedrock_foundation_model.cohere_command_light_text_v14.model_arn
  role_arn              = aws_iam_role.bedrock_custom_role.arn
  customization_type    = "FINE_TUNING"

  hyperparameters = {
    "epochCount"             = "1"
    "batchSize"              = "8"
    "learningRate"           = "0.00001"
    "earlyStoppingPatience"  = "6"
    "earlyStoppingThreshold" = "0.01"
    "evalPercentage"         = "20.0"
  }

  output_data_config {
    s3_uri = "s3://${aws_s3_bucket.model_training.id}/output_data_v1/"
  }

  training_data_config {
    s3_uri = "s3://${aws_s3_bucket.model_training.id}/training_data_v1/${terraform_data.training_data_fine_tune_v1.output}"
  }
}

resource "aws_bedrock_provisioned_model_throughput" "cm_cohere_provisioned_v1" {
  provisioned_model_name = "${aws_bedrock_custom_model.cm_cohere_v1.custom_model_name}-provisioned"
  model_arn              = aws_bedrock_custom_model.cm_cohere_v1.custom_model_arn
  model_units            = 1
}
