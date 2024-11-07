module "network" {
  source                = "../../modules/network"
  bedrock_location      = var.bedrock_location
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "bedrock" {
  source = "../../modules/bedrock"

}

/*module "database" {
  source = "../../modules/database"
  vpc_id = ""
  private_subnets = ""
}

module "secretmanager" {
  source = "../../modules/secretmanager"
}*/