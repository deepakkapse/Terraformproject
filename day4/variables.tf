variable "resource_group" {
  type    = string
  default = "1-3b6f50bc-playground-sandbox"
}
variable "resource_group_location" {
  type    = string
  default = "South Central US"

}
variable "storage_accountname" {
  type        = string
  description = "enter the storage account name"

}

variable "admin_name" {
  type    = string
  default = "deepak"

}

variable "admin_pass" {
  type    = string
  default = "Azure@12345"

}
