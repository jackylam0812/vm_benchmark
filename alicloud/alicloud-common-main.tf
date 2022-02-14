locals {
  appid = "xxx" # please change to your azure client id
  password = "xxx" # please change to your azure service principal password
  tenantid = "xxx" # please change to your azure tenantid id
  storage_account = "xxx"  # Azure Storage Account you want to save the result
  container = "xxx" # Blob Container you want to save the result
  startup_script = templatefile( "D:\\Terrform\\startup.sh", { 
      appid = local.appid
      password = local.password
      tenantid = local.tenantid
      storage_account = local.storage_account
      container = local.container
      } ) 
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}