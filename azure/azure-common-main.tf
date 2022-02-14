locals {
  appid = var.azure_client_id
  password = var.azure_client_secret
  tenantid = var.azure_tenant_id
  storage_account = "xxx"  # Azure Storage Account you want to save the result
  container = "xxx" # Blob Container you want to save the result
  benchmark = "coremark-1.0.1 sysbench-1.1.0" # testing suite installation, please choose the suite which you want to test. please viste https://openbenchmarking.org/ for details.
  startup_script = templatefile( "D:\\Terrform\\startup.sh", { 
      appid = local.appid
      password = local.password
      tenantid = local.tenantid
      storage_account = local.storage_account
      container = local.container
      benchmark = local.benchmark
      } ) 
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}