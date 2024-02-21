module "monitoring" {
  source              = "../../modules/monitoring"
  location            = module.vnetwork.location
  log_analytics_retention_days = 31 
}