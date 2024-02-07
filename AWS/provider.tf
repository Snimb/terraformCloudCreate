provider "aws" {
  region = "eu-west-1"  # Change this to your preferred region
  shared_credentials_file = "/path/to/.aws/credentials"
  profile                 = "default"
}