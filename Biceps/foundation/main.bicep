// Setting the scope to subscription
targetScope = 'subscription'

param location string = 'westeurope'
param stgAccountRgName string
param stgAccountName string
param stgAccountContainerName string

resource rg_state 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: stgAccountRgName
  location:location
}

// Deploying storage account using module
module stg './storage.bicep' = {
  name: 'storageDeployment'
  scope: rg_state    // Deployed in the scope of resource group we created above
  params: {
    stgAccountName: stgAccountName
    stgAccountContainerName: stgAccountContainerName
    location:rg_state.location
  }
}

// Deploying key vault using module
module keyvault './keyvault.bicep' = {
  name: 'keyvaultDeployment'
  scope: rg_state    // Deployed in the scope of resource group we created above
  params: {
    location:rg_state.location
  }
}
