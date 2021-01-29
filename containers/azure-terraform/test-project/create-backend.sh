#!/bin/bash
echo "create resource group"
az group create --name $TF_BACKEND_RESOURCE_GROUP --location $TF_BACKEND_LOCATION
echo "create storage account"
az storage account create --resource-group $TF_BACKEND_RESOURCE_GROUP --name $TF_BACKEND_STORAGE_ACCOUNT --sku Standard_LRS --encryption-services blob
echo "create blob container for tf state files"
az storage container create --name $TF_BACKEND_CONTAINER --account-name $TF_BACKEND_STORAGE_ACCOUNT --auth-mode login

