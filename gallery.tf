# Azure Compute Gallery -- galeria i definicja obrazu bazowego (bezpłatne). Wersje obrazów
# budowane są Packerem w Laboratorium 7b; płaci się tylko za przechowywanie wersji.
# Dokładana do lab002-common-resources w Laboratorium 7b; obraz używany jest w Laboratorium 7c.
resource "azurerm_shared_image_gallery" "common" {
  name                = local.common.gallery # tylko litery, cyfry, _ i .
  resource_group_name = azurerm_resource_group.common["common"].name
  location            = azurerm_resource_group.common["common"].location
  description         = "Galeria obrazów VM dla labów ${local.year}"

  tags = local.project_tags
}

resource "azurerm_shared_image" "base" {
  name                = local.common.image_base
  gallery_name        = azurerm_shared_image_gallery.common.name
  resource_group_name = azurerm_resource_group.common["common"].name
  location            = azurerm_resource_group.common["common"].location
  os_type             = "Linux"
  hyper_v_generation  = "V2" # jak obraz źródłowy Packera (Debian 13, generacja 2)

  identifier {
    publisher = local.course
    offer     = "debian13"
    sku       = "base"
  }

  tags = local.project_tags
}

output "gallery" {
  description = "Galeria obrazów i definicja obrazu bazowego"
  value = {
    name   = azurerm_shared_image_gallery.common.name
    images = [azurerm_shared_image.base.name]
  }
}
