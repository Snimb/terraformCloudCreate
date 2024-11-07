module "vpc" {
  source = "../../modules/vpc"

}

module "s3" {
  source = "../../modules/s3"

}

module "glue" {
  source                = "../../modules/glue"
  data_lake_bucket_name = var.data_lake_bucket_name
}

module "redshift" {
  source                = "../../modules/redshift"
  master_password       = var.master_password
  master_username       = var.master_username
  database_name         = var.database_name
  subnet_ids            = var.subnet_ids
  vpc_security_group_id = var.vpc_security_group_id

}

module "rds" {
  source             = "../../modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "lambda" {
  source                = "../../modules/lambda"
  sharepoint_api_key    = var.sharepoint_api_key
  confluence_api_key    = var.confluence_api_key
  lambda_code_s3_bucket = var.lambda_code_s3_bucket
  lambda_code_s3_key    = var.lambda_code_s3_key
}

module "sageMaker" {
  source = "../../modules/sageMaker"

}

module "kendra" {
  source = "../../modules/kendra"

}

module "quicksight" {
  source = "../../modules/quicksight"

}

module "textract" {
  source                = "../../modules/textract"
  lambda_code_s3_bucket = var.lambda_code_s3_bucket
  lambda_code_s3_key    = var.lambda_code_s3_key

}

module "secretsManager" {
  source      = "../../modules/secretsManager"
  db_password = var.db_password
  db_username = var.db_username
}

module "athena" {
  source = "../../modules/athena"
}

module "bedrock" {
source = "../../modules/bedrock"  
}