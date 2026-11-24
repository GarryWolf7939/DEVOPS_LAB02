# Wspólna sieć wirtualna dla labów 6-10 (VM, VMSS, kontenery) -- sama sieć i podsieci są
# bezpłatne. Laby odczytują ją przez `data "azurerm_virtual_network"` / `azurerm_subnet`.
# Dokładana do lab002-common-resources w Laboratorium 6; Azure Bastion -- w Laboratorium 8.
variable "vnet_address_space" {
  description = "Przestrzeń adresowa wspólnej sieci wirtualnej"
  type        = list(string)
  default     = ["10.0.0.0/20"]
}

variable "subnets_map" {
  description = "Podsieci dla labów: klucz -> prefiks adresu (nazwa: snet-labs-<klucz>)"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
    c = "10.0.3.0/24"
  }
}

variable "default_outbound_access_enabled" {
  description = <<-EOT
  Domyślny dostęp wychodzący do internetu z podsieci (bez NAT Gateway).
  Domyślnie wyłączony -- podsieci prywatne; NAT Gateway jest ćwiczeniem opcjonalnym lab 6.
  EOT
  type        = bool
  default     = false
}

resource "azurerm_virtual_network" "common" {
  name                = local.common.vnet
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.common["common"].location
  resource_group_name = azurerm_resource_group.common["common"].name

  tags = local.project_tags

  # Sieć istnieje do końca semestru -- blokada przypadkowego `tofu destroy`; przy sprzątaniu
  # po semestrze blokadę usuwa się ręcznie
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "labs" {
  for_each = var.subnets_map

  name                 = "snet-labs-${each.key}"
  resource_group_name  = azurerm_resource_group.common["common"].name
  virtual_network_name = azurerm_virtual_network.common.name
  address_prefixes     = [each.value]

  # Brak domyślnego wyjścia do internetu; NAT Gateway -- opcjonalnie w lab 6
  default_outbound_access_enabled = var.default_outbound_access_enabled

  # Delegację podsieci ustawia sama usługa (np. Container Apps w lab 10 dla snet-labs-b) --
  # bez ignore_changes kolejny apply w tym repo próbowałby ją usunąć
  lifecycle {
    ignore_changes = [delegation]
  }
}

output "vnet" {
  description = "Wspólna sieć: nazwa, id i podsieci (dla bloków data w labach 6-10)"
  value = {
    name    = azurerm_virtual_network.common.name
    id      = azurerm_virtual_network.common.id
    subnets = { for k, s in azurerm_subnet.labs : k => s.name }
  }
}
