variable "azure_devops_org_url" {
  type        = string
  description = "Azure DevOps organization URL"
}

variable "azure_devops_org" {
  type        = string
  description = "Azure DevOps organization"
}

variable "azure_devops_pat" {
  type        = string
  description = "Personal Access Token"
  sensitive   = true
}

variable "project_name" {
  default     = "tf-sample-project"
  description = "Name of the Azure DevOps project"
}

variable "repo_name" {
  default     = "sample-repo"
  description = "Name for the imported repository"
}

variable "github_repo_url" {
  default     = "https://github.com/chilkaditya/Ecommerce-app.git"
  description = "Public Git repo to import"
}
