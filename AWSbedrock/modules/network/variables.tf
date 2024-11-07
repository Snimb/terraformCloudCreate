variable "bedrock_location" {
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet"
  type        = string
}


variable "public_subnet_cidr" {
  type = string
  description = "CIDR block for the public subnet"
}


