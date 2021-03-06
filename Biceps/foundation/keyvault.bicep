// Setting the scope to resourceGroup, it is the default but shown here for better readability
targetScope = 'resourceGroup'

// we get the details as parameters from main
param vaultName string
param location string = resourceGroup().location

//az ad user list for object id

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaultName
  location: location
  tags: {
    tagName1: 'infra'
  }

  properties: {
    accessPolicies: [
      {
        objectId: '9b71ba09-202e-484c-95ad-7755b4fc5836'
        tenantId: subscription().tenantId
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
    }
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
  }
}