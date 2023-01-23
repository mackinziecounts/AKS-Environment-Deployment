//Create an Azure Key Vault
targetScope = 'resourceGroup'

param keyVaultName string 
param keyVaultLocationParam string = resourceGroup().location
param keyVaultSkuFamily string = 'A'
param keyVaultSkuName string = 'Standard'
param keyVaultTenantId string
param keyVaultObjectId string


resource asfas 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: keyVaultLocationParam
  properties: {
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    tenantId: keyVaultTenantId
    accessPolicies: [
      {
        objectId: keyVaultObjectId
        tenantId: keyVaultTenantId
        permissions: {
          keys: ['all']
          secrets: ['all']
        }
      }
    ]
    sku: {
      family: keyVaultSkuFamily
      name: keyVaultSkuName
    }
  }
}


