//Az AD Role Assignment

param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param principalId string
param userPrincipalName string

targetScope = 'tenant'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: userPrincipalName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'User'
  }
}
