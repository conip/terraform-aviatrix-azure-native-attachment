


variable "name" {
  description = "Custom name for VNETs, gateways, and firewalls"
  type        = string
}

variable "cidr" {
  description = "The CIDR range to be used for the VNET"
  type        = string
  default     = ""
}

variable "region" {
  description = "The Azure region to deploy this module in"
  type        = string
}

# variable "arm_subscription_id" {
#   description = "Azure ARM Subscription ID. Required when creating an account for Azure"
#   type        = string
# }

# variable "arm_directory_id" {
#   description = "Azure ARM Directory ID. Required when creating an account for Azure"
#   type        = string
# }
# variable "arm_application_id" {
#   description = "Azure ARM Application ID. Required when creating an account for Azure"
#   type        = string
# }
# variable "arm_application_key" {
#   description = "Azure ARM Application key. Required when creating an account for Azure"
#   type        = string
# }

variable "attached" {
  description = "Set to false if you don't want to attach spoke to transit."
  type        = bool
  default     = true
}

variable "security_domain" {
  description = "Provide security domain name to which spoke needs to be deployed. Transit gateway mus tbe attached and have segmentation enabled."
  type        = string
  default     = ""
}

variable "transit_gw" {
  description = "Transit gateway to attach spoke in the same region"
  type        = map(string)
  default = {
    "Central US"           = "avx-central-us-transit",
    "Germany West Central" = "avx-germany-transit",
    "South East Asia"      = "avx-south-east-asia-transit",
    "West Europe"          = "avx-west-europe-transit"
  }
}

variable "inspection" {
  description = "Set to true to enable east/west Firenet inspection. Only valid when transit_gw is East/West transit Firenet"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
}

locals {
  lower_name = replace(lower(var.name), " ", "-")
  prefix     = var.prefix ? "az-" : ""
  suffix     = var.suffix ? "-spoke" : ""
  cidr       = var.use_existing_vnet ? "10.0.0.0/20" : var.cidr #Set dummy if existing VNET is used.
  name       = "${local.prefix}${local.lower_name}${local.suffix}"
  cidrbits   = tonumber(split("/", local.cidr)[1])
  newbits    = 26 - local.cidrbits
  netnum     = pow(2, local.newbits)
  subnet     = var.use_existing_vnet ? var.gw_subnet : (var.insane_mode ? cidrsubnet(local.cidr, local.newbits, local.netnum - 2) : aviatrix_vpc.default[0].public_subnets[0].cidr)
  ha_subnet  = var.use_existing_vnet ? var.gw_subnet : (var.insane_mode ? cidrsubnet(local.cidr, local.newbits, local.netnum - 1) : aviatrix_vpc.default[0].public_subnets[0].cidr)
  cloud_type = var.china ? 2048 : 8
}


#------------

variable "prefix" {
  description = "Boolean to determine if name will be prepended with avx-"
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Boolean to determine if name will be appended with -spoke"
  type        = bool
  default     = true
}


variable "transit_gw_egress" {
  description = "Name of the transit gateway to attach this spoke to"
  type        = string
  default     = ""
}

variable "transit_gw_route_tables" {
  description = "Route tables to propagate routes to for transit_gw attachment"
  type        = list(string)
  default     = []
}

variable "transit_gw_egress_route_tables" {
  description = "Route tables to propagate routes to for transit_gw2 attachment"
  type        = list(string)
  default     = []
}




variable "attached_gw_egress" {
  description = "Set to false if you don't want to attach spoke to transit_gw_egress."
  type        = bool
  default     = true
}

variable "resource_group" {
  description = "Provide the name of an existing resource group."
  type        = string
  default     = null
}

variable "use_existing_vnet" {
  description = "Set to true to use existing VNET."
  type        = bool
  default     = false
}

variable "vnet_id" {
  description = "vnet ID, for using an existing vnet."
  type        = string
  default     = ""
}


variable "china" {
  description = "Set to true if deploying this module in Azure China."
  type        = bool
  default     = false
}




