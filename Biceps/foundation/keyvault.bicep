// Setting the scope to resourceGroup, it is the default but shown here for better readability
targetScope = 'resourceGroup'

// we get the details as parameters from main
param vaultName string = 'infra-key-vault'
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaultName
  location: location
  tags: {
    tagName1: 'infra'
  }
  properties: {
    accessPolicies: [
      {
        applicationId: 'string'
        objectId: 'string'
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
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
    }
  }
}