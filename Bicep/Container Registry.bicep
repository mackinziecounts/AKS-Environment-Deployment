targetScope = 'resourceGroup'

@minLength(5)
@maxLength(50)
param acrName string = '${resourceGroup().name}bmprojacr'
//azure container registries must be lowercase
//this is why acrName is wrapped inside toLower() function below
param location string = resourceGroup().location
param acrSku string = 'Standard'

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: toLower(acrName)
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
