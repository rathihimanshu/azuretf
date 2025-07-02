resource "azurerm_resource_group" "rg" {
  name     = "vnet-demo-rg"
  location = "East US"
}

resource "azurerm_public_ip" "nat_ip" {
  name                = "nat-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
  name                = "nat-gw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_ip.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "public" {
  name                = "public-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_all_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_all_outbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "private" {
  name                = "private-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_all_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_all_outbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_route_table" "public_rt" {
  name                = "public-rt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet" "public1" {
  name                 = "public-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "public2" {
  name                 = "public-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "private1" {
  name                 = "private-subnet-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "private2" {
  name                 = "private-subnet-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "public1_assoc" {
  subnet_id                 = azurerm_subnet.public1.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "public2_assoc" {
  subnet_id                 = azurerm_subnet.public2.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private1_assoc" {
  subnet_id                 = azurerm_subnet.private1.id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_network_security_group_association" "private2_assoc" {
  subnet_id                 = azurerm_subnet.private2.id
  network_security_group_id = azurerm_network_security_group.private.id
}

resource "azurerm_subnet_route_table_association" "public1_rt_assoc" {
  subnet_id      = azurerm_subnet.public1.id
  route_table_id = azurerm_route_table.public_rt.id
}

resource "azurerm_subnet_route_table_association" "public2_rt_assoc" {
  subnet_id      = azurerm_subnet.public2.id
  route_table_id = azurerm_route_table.public_rt.id
}

resource "azurerm_subnet_nat_gateway_association" "private1_nat_assoc" {
  subnet_id      = azurerm_subnet.private1.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private2_nat_assoc" {
  subnet_id      = azurerm_subnet.private2.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}


