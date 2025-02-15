variable "azure_region" {
    type = string
    default =  "eastus"  

}
variable "resource_group_name" {
    type = string
    default = "azure-demo-rg"
  
}

variable "cluster_name" {
    type = string 
    default = "azure-demo-cluster"
  
}

variable "vnet_address_space" {
    type = list(string)
    default = ["10.1.0.0/16"]
  
}

variable "subnet_address_prefixes" {
    type = list(string)
    default = ["10.1.1.0/24", "10.1.2.0/24"]
  
}

variable "node_count" {
    type = number
    default = 2
}
variable "node_size" {
    type = string
    default = "Standard_DS2_v2"
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}
