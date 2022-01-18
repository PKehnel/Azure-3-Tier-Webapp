 terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

}

#Create a resource group to hold all the resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.env}"
  location = "${var.azure_region}"
}

#Create the VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-usecase3"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

#Create the subnet that hold the web-servers
resource "azurerm_subnet" "subnet_web" {
  name                 = "subnet-web"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.1.0/24"]
}

#Create the subnet that hold the db-servers
resource "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

#Create the PIP for the loadbalancer
resource "azurerm_public_ip" "pip_lb" {
  name                = "publicIPForLB"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"
}

#Create the the loadbalancer and assign it the IP from the previous step
resource "azurerm_lb" "lb" {
  name                = "loadBalancer"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }
}

#Create the backend pool for the LB that will hold the private IPs of the webservers 
resource "azurerm_lb_backend_address_pool" "backendAddressPool" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
}

#Create 2 FrontEnd NICs for the webservers in the web subnet
resource "azurerm_network_interface" "nic_webservers" {
  count               = 2
  name                = "webnic-${count.index}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "dynamic"
  }
}

#Create an availability set with two fault/update domains, so each webserver is placed into its own domain
resource "azurerm_availability_set" "avset" {
  name                          = "avset"
  location                      = "${azurerm_resource_group.rg.location}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count   = 2
  platform_update_domain_count  = 2
  managed                       = true
}
 
resource "azurerm_virtual_machine" "web_servers" {
  count                 = 2
  name                  = "webserver-${count.index}"
  location              = "${azurerm_resource_group.rg.location}"
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = [element(azurerm_network_interface.nic_webservers.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "webserver-${count.index}"
    admin_username = "kyndryl"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "uit-demo"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo systemctl enable nginx.service",
      "sudo service nginx start",
    ]
  }
}

