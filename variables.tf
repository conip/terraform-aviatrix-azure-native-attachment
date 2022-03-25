variable "spoke_account_name" {
  description = "Azure Account defined under controller - being used to create AZ resources from controller itself"
  type = string
}

variable "name" {
  description = "custom name for VNETs, gateways, and firewalls"
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
  #cidr       = var.use_existing_vnet ? "10.0.0.0/20" : var.cidr #Set dummy if existing VNET is used.
  cidr       = var.cidr
  name       = "${local.prefix}${local.lower_name}${local.suffix}"
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




