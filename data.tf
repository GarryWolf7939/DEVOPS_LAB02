# Krok 2: Pobranie danych aktualnej subskrypcji Azure
data "azurerm_subscription" "current" {}

# Krok 3: Pobranie danych tożsamości wykonującej wdrażanie
data "azurerm_client_config" "current" {}

# Krok 3 (Opcjonalny odczyt klucza SOPS, gdy create_sops_key = false)
