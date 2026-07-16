variable "environment" {
  type        = string
  description = "Environment name, used in resource group names (e.g. dev -> rg-dev-web)."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resource groups."
}
