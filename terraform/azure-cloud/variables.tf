variable "vm_username" {
  description = "Username for the VM login"
  default     = "azureuser"
}

variable "vm_password" {
  description = "Password for the VM login"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Azure region for resources"
  default     = "East US"
}

variable "azure_devops_org_url" {
  description = "URL of the Azure DevOps organization"
}

variable "azure_devops_pat" {
  description = "Personal Access Token for Azure DevOps"
  type        = string
  sensitive   = true
}

variable "agent_pool_name" {
  description = "Name of the Azure DevOps agent pool"
  default     = "tf-agentpool"
}