targetScope = 'resourceGroup'

@minLength(5)
@maxLength(50)
param acrName string = '${resourceGroup().name}bmprojacr'
param location string = resourceGroup().location
param acrSku string = 'Standard'

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
output test string = acrResource.id
