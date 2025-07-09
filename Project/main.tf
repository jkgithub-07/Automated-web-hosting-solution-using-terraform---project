terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-rg"
  location = var.location

  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.env}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.env}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku = "Standard" 

  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "${var.env}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}

# Backend Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
  
}

# Health Probe
resource "azurerm_lb_probe" "lbp" {
  name                = "http-probe"
  
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}

# LB Rule
resource "azurerm_lb_rule" "lbrule" {
  name                            = "http-rule"
  loadbalancer_id                 = azurerm_lb.lb.id
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = "PublicIPAddress"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                        = azurerm_lb_probe.lbp.id
}




# Network Interfaces + VMs
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "${var.env}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = 2
  name                = "${var.env}-vm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(
  templatefile(
    "scripts/install_web.sh.tmpl",
    {
      index_html = templatefile(
        "web/index.html.tmpl",
        {
          env      = var.env,
          vm_index = count.index
        }
      ),
      style_css = file("web/style.css")
    }
  )
)


  tags = {
    environment = var.env
    project     = "iac-tool"
  }
}


resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.env}-web-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}



resource "azurerm_network_interface_backend_address_pool_association" "nic_association" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}
