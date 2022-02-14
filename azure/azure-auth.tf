#Azure authentication variables
variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
  default = "xxx"  # Please input your Azure Subscription ID
}

variable "azure_client_id" {
  type        = string
  description = "Azure Client ID"
  default = "xxx" # Please input your Azure Client ID
}

variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
  default = "xxx" # Please input your Azure Client Secret
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
  default = "xxx" # Please input your Azure Tenant ID
}