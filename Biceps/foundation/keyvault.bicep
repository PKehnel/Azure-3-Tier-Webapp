param stgAccountName string
param stgAccountContainerName string
param location string = resourceGroup().location


resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: infra-keyvault
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
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
    }
  }
}