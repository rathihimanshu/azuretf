export RG_NAME="tf-lock-demo"
export LOCATION="eastus"
export STORAGE_ACCOUNT="tfstatelock$RANDOM"
export CONTAINER_NAME="tfstate"

az group create --name $RG_NAME --location $LOCATION

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG_NAME \
  --sku Standard_LRS \
  --encryption-services blob

ACCOUNT_KEY=$(az storage account keys list --resource-group $RG_NAME --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)

az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

az storage account list --query "[].name" -o table



terraform {
  backend "azurerm" {
    resource_group_name  = "tf-lock-demo"
    storage_account_name = "<your-storage-account>"
    container_name       = "tfstate"
    key                  = "locked/demo.tfstate"
  }
}
