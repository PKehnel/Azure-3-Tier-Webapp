// Setting the scope to resourceGroup, it is the default but shown here for better readability
targetScope = 'resourceGroup'

// we get the storage account details as parameters from main
param stgAccountName string
param stgAccountContainerName string
param location string = resourceGroup().location

resource sa_state 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: stgAccountName
  location: location
  sku:  {
    name: 'Standard_LRS'
  }
  kind:'StorageV2'
  properties:{
    accessTier:'Hot'
  }
}

resource sa_state_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${sa_state.name}/default/${stgAccountContainerName}'
}
