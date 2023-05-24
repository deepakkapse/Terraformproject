variable "resource_group" {
  type    = string
  default = "1-800a82c8-playground-sandbox"
}
variable "resource_group_location" {
  type    = string
  default = "West US"

}
/*
variable "storage_accountname" {
  type        = string
  description = "enter the storage account name"

}
*/

variable "admin_name" {
  type    = string
  default = "deepak"

}

variable "admin_pass" {
  type    = string
  default = "Azure@12345"

}
/*
variable "tenantid" {
  default = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  
}
variable "usertenant" {
  default = "cloud_user_p_8028563b@realhandsonlabs.com"
  
}
*/