terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "terraform-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}


resource "azurerm_public_ip" "agent_ip" {
  name                = "terraform-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Use Standard SKU for better security and performance
}

resource "azurerm_network_interface" "nic" {
  name                = "terraform-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.agent_ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "terraform-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # You can restrict this to your IP
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "agent_vm" {
  name                            = "terraform-agent-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_B1s"  # Smaller size for student plan
  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/home/${var.vm_username}/script.sh"
    connection {
      type     = "ssh"
      user     = var.vm_username
      password = var.vm_password
      host     = azurerm_public_ip.agent_ip.ip_address
    }

  }

  provisioner "remote-exec" {
    inline = [
    "chmod +x /home/${var.vm_username}/script.sh",
    "AZDO_ORG_URL='${var.azure_devops_org_url}' AZDO_PAT='${var.azure_devops_pat}' AZDO_POOL='${var.agent_pool_name}' /home/${var.vm_username}/script.sh"
    ]

    connection {
      type     = "ssh"
      user     = var.vm_username
      password = var.vm_password
      host     = azurerm_public_ip.agent_ip.ip_address
    }
  }

  # depends_on = [azuredevops_agent_pool.self_hosted_pool]
}

resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "tf-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "tf-aks1"

  default_node_pool {
    name       = "default"
    vm_size    = "standard_a2_v2"
    enable_auto_scaling = true
    min_count  = 1
    max_count  = 2
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }

  # tags = {
  #   Environment = "Production"
  # }
}

resource "azurerm_container_registry" "acr" {
  name                = "TfcontainerRegistry01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
  # georeplications {
  #   location                = var.location
  #   zone_redundancy_enabled = true
  #   tags                    = {}
  # }

}
