terraform {
  #version="~4.7"
  required_providers {
    azurerm = {
      source = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.57"
    }
  }
  
}

provider "azurerm" {
  #this skip line is mandatory
  skip_provider_registration = true
  #subscription id found in subscriptions  
  subscription_id = "80ea84e8-afce-4851-928a-9e2219724c69"
  #client id is given by azure sandbox,if you create own fetch from there
  client_id = "efae2a62-bf8a-4000-a184-39c3867d01ea"
  #tenant_id = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  client_secret = "-ei8Q~PGjsv6QngkI21IhPiBMP-5s0isRkJGia~7" #provided by lab
  features {
    
  }

}

 /* do az login and then
  terraform import azurerm_resource_group.resource1 /subscriptions/80ea84e8-afce-4851-928a-9e2219724c69/resourceGroups/1-c57f7fa3-playground-sandbox  
  the above code has resource group name and subscription id
  then all good to run*/