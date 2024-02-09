# Calculate configuration settings
locals {
  shared_buffers           = local.total_memory_8kb / 4     # 25% of total memory
  work_mem                 = local.total_memory_kb / 16     # 6% of total memory
  maintenance_work_mem     = local.total_memory_kb / 4      # 25% of total memory
  effective_cache_size     = local.total_memory_kb / 2      # 50% of total memory
  max_wal_size             = var.total_memory_mb / 4        # 25% of total memory
  effective_io_concurrency = var.cpu_cores * 2              # 2 times the cpu cores
  total_memory_kb          = var.total_memory_mb * 1024     # total memory in kb
  total_memory_8kb         = var.total_memory_mb * 1024 / 8 # total memory in 8kb
}

locals {
  environment = terraform.workspace != "default" ? terraform.workspace : ""
}