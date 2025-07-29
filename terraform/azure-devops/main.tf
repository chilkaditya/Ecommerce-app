terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = var.azure_devops_org_url
  personal_access_token = var.azure_devops_pat
}

resource "azuredevops_project" "sample_project" {
  name       = var.project_name
  visibility = "private"
  version_control = "Git"
  work_item_template = "Agile"
  description = "Project created via Terraform"
}

# resource "azuredevops_git_repository" "empty_repo" {
#   project_id = azuredevops_project.sample_project.id
#   name       = var.repo_name

#   initialization {
#     init_type = "Clean"
#   }
# }

# resource "null_resource" "import_repo" {
#   depends_on = [azuredevops_git_repository.empty_repo]
#   provisioner "local-exec" {
#     command = "bash ./import.sh ${var.azure_devops_pat}"
#   }
# }

resource "azuredevops_git_repository" "example-import" {
  project_id = azuredevops_project.sample_project.id
  name       = var.repo_name
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = var.github_repo_url
  }
}

resource "azuredevops_agent_pool" "tf_pool" {
  name           = "tf-agentpool"
  auto_provision = false
  auto_update    = false
}



