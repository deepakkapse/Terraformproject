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
  subscription_id = "2213e8b1-dbc7-4d54-8aff-b5e315df5e5b"
  #client id is given by azure sandbox,if you create own fetch from there
  client_id = "4695b266-aa7b-4bce-a08a-9e4bc881572f"
  #tenant_id = "84f1e4ea-8554-43e1-8709-f0b8589ea118"
  client_secret = "cyC8Q~vWnKt-3k8MQH24buOa~8SJOfbDoQqREaKC" #provided by lab
  features {

  }

}



/* do az login and then
  terraform import azurerm_resource_group.resource1 /subscriptions/80ea84e8-afce-4851-928a-9e2219724c69/resourceGroups/1-c57f7fa3-playground-sandbox  
  the above code has resource group name and subscription id
  then all good to run*/