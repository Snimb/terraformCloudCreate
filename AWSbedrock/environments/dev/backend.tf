terraform {
  backend "s3" {
    bucket         = "tf-itm8-s3-bucket"
    key            = "state/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-state"
  }
}
