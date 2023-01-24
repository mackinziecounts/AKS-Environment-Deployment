targetScope = 'resourceGroup'

param storLocation string = resourceGroup().location
param storSku string = 'Standard_GRS'
param storKind string = 'StorageV2'
param storTier string = 'Hot'
param StorAccName string
//storage account name must be lowercase


resource symbolicname 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: toLower(StorAccName)
  location: storLocation
  sku: {
    name: storSku
  }
  kind: storKind
  properties: {
    accessTier: storTier
    allowBlobPublicAccess: true
    allowCrossTenantReplication: true
    allowedCopyScope: 'AAD'
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    dnsEndpointType: 'Standard'
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    isHnsEnabled: false
    isLocalUserEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}
output storOutId string = symbolicname.id
output storOutProp string = symbolicname.properties.provisioningState
