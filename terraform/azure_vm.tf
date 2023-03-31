# Konfiguration einer VM in der Azure Cloud
terraform {
  # Setzen der notwendigen Provider-Informationen
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.46.0"
    }
  }
}

# Konfiguration des Azure Providers
provider "azurerm" {
  features {}

  # Setzen der Subscription ID
  subscription_id = "b341d6fb-0155-4d01-80d3-d9e5bb0641c1"
}

# Erzeugen einer Resource Group
resource "azurerm_resource_group" "example" {
  # Name der Resource Group
  name     = "my-resource-group"
  # Standort der Resource Group
  location = "francecentral"
}

# Erzeugen eines Virtual Networks
resource "azurerm_virtual_network" "example" {
  # Name des Virtual Networks
  name                = "my-virtual-network"
  # IP-Adresse des Virtual Networks
  address_space       = ["10.0.0.0/16"]
  # Standort des Virtual Networks
  location            = "${azurerm_resource_group.example.location}"
  # Name der Resource Group, in der das Virtual Network erzeugt wird
  resource_group_name = "${azurerm_resource_group.example.name}"
}

# Erzeugen eines Subnets
resource "azurerm_subnet" "example" {
  # Name des Subnets
  name                 = "my-subnet"
  # IP-Adresse des Subnets
  address_prefixes     = ["10.0.1.0/24"]
  # Name des Virtual Networks, zu dem das Subnet gehört
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  # Name der Resource Group, in der das Subnet erzeugt wird
  resource_group_name  = "${azurerm_resource_group.example.name}"
}

# Erzeugen einer Network Interface
resource "azurerm_network_interface" "example" {
  # Name der Network Interface
  name                = "my-nic"
  # Standort der Network Interface
  location            = "${azurerm_resource_group.example.location}"
  # Name der Resource Group, in der die Network Interface erzeugt wird
  resource_group_name = "${azurerm_resource_group.example.name}"

  # Konfiguration der IP-Adresse
  ip_configuration {
    name                          = "my-ip-configuration"
    # ID des Subnets, zu dem die IP-Adresse gehört
    subnet_id                     = "${azurerm_subnet.example.id}"
    # Zuweisung der privaten IP-Adresse
    private_ip_address_allocation = "Dynamic"
    # ID der öffentlichen IP-Adresse
    public_ip_address_id          = "${azurerm_public_ip.example.id}"
  }
}

# Erzeugen einer öffentlichen IP-Adresse
resource "azurerm_public_ip" "example" {
  # Name der öffentlichen IP-Adresse
  name                = "my-public-ip"
  # Standort der öffentlichen IP-Adresse
  location            = "${azurerm_resource_group.example.location}"
  # Name der Resource Group, in der die öffentliche IP-Adresse erzeugt wird
  resource_group_name = "${azurerm_resource_group.example.name}"
  # Zuweisung der IP-Adresse
  allocation_method   = "Dynamic"
}

# Erzeugen einer Network Security Group
resource "azurerm_network_security_group" "example" {
  # Name der Network Security Group
  name                = "my-nsg"
  # Standort der Network Security Group
  location            = "${azurerm_resource_group.example.location}"
 # Name der Resource Group, in der die Network Security Group erzeugt wird
  resource_group_name = "${azurerm_resource_group.example.name}"

  # Konfiguration der Security Rule
  security_rule {
    name                       = "SSH"
    # Priorität der Security Rule
    priority                   = 1001
    # Richtung der Security Rule
    direction                  = "Inbound"
    # Zugriff auf die Security Rule
    access                     = "Allow"
    # Protokoll der Security Rule
    protocol                   = "Tcp"
    # Portbereich der Quelle
    source_port_range          = "*"
    # Portbereich des Ziels
    destination_port_range     = "22"
    # IP-Adresse der Quelle
    source_address_prefix      = "*"
    # IP-Adresse des Ziels
    destination_address_prefix = "*"
  }

  security_rule {
    name                        = "allow-inbound-traffic"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "8080"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}

# Zuweisen der Network Security Group zur Network Interface
resource "azurerm_network_interface_security_group_association" "example" {
  # ID der Network Interface
  network_interface_id      = "${azurerm_network_interface.example.id}"
  # ID der Network Security Group
  network_security_group_id = "${azurerm_network_security_group.example.id}"
}

# Erzeugen einer virtuellen Maschine
resource "azurerm_virtual_machine" "example" {
  # Name der virtuellen Maschine
  name                  = "my-vm"
  # Standort der virtuellen Maschine
  location              = "${azurerm_resource_group.example.location}"
  # Name der Resource Group, in der die virtuelle Maschine erzeugt wird
  resource_group_name   = "${azurerm_resource_group.example.name}"
  # ID der Network Interface, die der virtuellen Maschine zugewiesen wird
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  # Größe der virtuellen Maschine
  vm_size               = "Standard_B1ls"

  # Konfiguration der Identity
  identity {
    type = "SystemAssigned"
  }

  # Konfiguration des Storage Images
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Konfiguration des Storage OS Disk
  storage_os_disk {
    name              = "my-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Konfiguration des OS Profils
  os_profile {
    computer_name  = "my-vm"
    admin_username = "azureuser"
  }

  # Konfiguration des OS Profiles für Linux
  os_profile_linux_config {
    # Deaktivieren der Passwort-Authentifizierung
    disable_password_authentication = true
    ssh_keys {
      # Pfad zur SSH-Datei
      path     = "/home/azureuser/.ssh/authorized_keys"
      # SSH-Key
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC++nOE/n+/bOIP04OtB31SoqiCIQXxxWpZDjhY++cDKNWmb80ysBI+m8ZKymcnJZXisepE62utyqUXUX//neyAZNeOpegfqmLMiBvcIG2dkVBQD8V/Q39rwjbgbofRU3Dal9CrTYOO+VBdeB7FqfaSipUPvX+2YokmjfJO44FpG9OghGDvHhDLwquBnH5EtA5qmRs2VR0KxG/xDuXOA3fPrHLOPDXwnCLGkRriEogK+UbaYyCeWoJUexFHulngXo/QGyfFFLcy9m3vg1TLU3F20+4aQIqWLUP5N8ew8MPgonZshDtebAqGpsVx4nNl89XeapSu4y63R0rI1FJMq5P1yiZUB2rF90Q9OJuu7gYt8PxGEfjAKXpNR5b6fX+Ooz/DtKIx5R2kojFsA5DB7MGXs59iLa1QKVQAUXSXNct7hjoQgD7aHXLel8RIK817hb8lcXh8CUnLE9ODXs0WWzUdILDutknX9HINxxEaKDuchIYrHZWtXrS2lmia21pj6ss= emea\\gohlke@WAEJHPJ3NG"
    }
  }
}

resource "azurerm_cosmosdb_account" "example" {
  name                = "max-cosmosdb-account"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  consistency_policy {  
    consistency_level = "Session"
  }
  geo_location {
    location          = "switzerlandnorth"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "example" {
  name                = "my-mongo-db"
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_cosmosdb_account.example.name
}

resource "azurerm_cosmosdb_mongo_collection" "example" {
  name                = "qa_collection"
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_cosmosdb_account.example.name
  database_name       = azurerm_cosmosdb_mongo_database.example.name
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}

