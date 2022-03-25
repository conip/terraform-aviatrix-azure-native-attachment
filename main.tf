



# # Create an Azure Access Account
# resource "aviatrix_account" "default" {
#   account_name        = local.name
#   cloud_type          = 8
#   arm_subscription_id = var.arm_subscription_id
#   arm_directory_id    = var.arm_directory_id
#   arm_application_id  = var.arm_application_id
#   arm_application_key = var.arm_application_key
# }

resource "azurerm_resource_group" "spoke_rg" {
  name     = "rg-${local.name}"
  location = var.region
  tags     = var.tags
}

resource "azurerm_virtual_network" "vnet_spoke_default" {
  name                = "vnet-${local.name}"
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  address_space       = [var.cidr]
    subnet {
    name           = "subnet-${local.name}"
    address_prefix = cidrsubnet(var.cidr, 0, 0)
  }
  depends_on = [
    azurerm_resource_group.spoke_rg
  ]
}


# Create an Aviatrix Azure spoke native peering
resource "aviatrix_azure_spoke_native_peering" "native_vnet_attachment" {
  transit_gateway_name = var.transit_gw["${var.region}"]
  #spoke_account_name   = aviatrix_account.default.account_name
  spoke_account_name = var.spoke_account_name # to be removed and replaced by above line
  spoke_region       = var.region
  spoke_vpc_id       = "${azurerm_virtual_network.vnet_spoke_default.name}:${azurerm_resource_group.spoke_rg.name}:${azurerm_virtual_network.vnet_spoke_default.guid}"
  depends_on = [
    azurerm_virtual_network.vnet_spoke_default
  ]
}


resource "aviatrix_segmentation_security_domain_association" "default" {
  count                = length(var.security_domain) > 0 ? 1 : 0 #Only create resource when attached and security_domain is set.
  transit_gateway_name = var.transit_gw["${var.region}"]
  security_domain_name = var.security_domain
  attachment_name      = "${var.spoke_account_name}:${aviatrix_azure_spoke_native_peering.native_vnet_attachment.spoke_vpc_id}"
  depends_on = [
    aviatrix_azure_spoke_native_peering.native_vnet_attachment
  ] #Let's make sure this cannot create a race condition
}

# resource "aviatrix_transit_firenet_policy" "default" {
#   count                        = var.inspection ? 1 : 0
#   transit_firenet_gateway_name = var.transit_gw["${var.region}"]
#   inspected_resource_name      = ""
#   depends_on = [
#     aviatrix_azure_spoke_native_peering.native_vnet_attachment
#   ] #Let's make sure this cannot create a race condition
# }

