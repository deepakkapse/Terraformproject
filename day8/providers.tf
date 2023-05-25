terraform {
  #version="~4.7"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.57"
    }
  }

}

provider "azurerm" {
  #this skip line is mandatory
  skip_provider_registration = true
  #subscription id found in subscriptions  
  subscription_id = "0cfe2870-d256-4119-b0a3-16293ac11bdc"
  #client id is given by azure sandbox,if you create own fetch from there
  client_id = "331ebfbb-c4c9-4403-bbdc-ba07e7da5c15"
  #tenant_id = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  client_secret = "odh8Q~xLMj86ZV7zwnX.W8X7t9fCuVrJgMyo4cKk" #provided by lab
  features {

  }

}

/* do az login and then
  terraform import azurerm_resource_group.resource1 /subscriptions/80ea84e8-afce-4851-928a-9e2219724c69/resourceGroups/1-c57f7fa3-playground-sandbox  
  the above code has resource group name and subscription id
  then all good to run*/