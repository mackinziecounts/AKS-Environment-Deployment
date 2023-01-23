//create a pseudo root management group
targetScope = 'tenant'

@description('Name of your Pseudo-Root Management Group')
param pseudoRootMGName string

resource pseudoRootMGAlias 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: pseudoRootMGName
  scope: tenant()
  properties: {
    displayName: pseudoRootMGName
  }
}


//create management groups
param mgNames array = [
  'Child1'
]


resource FoundationMG 'Microsoft.Management/managementGroups@2021-04-01' = [for name in mgNames: {
  name: '${name}${pseudoRootMGName}'
  scope: tenant()
  properties: {
    displayName: '${name}${pseudoRootMGName}'
    details: {
      parent: {
        id: pseudoRootMGAlias.id
      }
    }
  }
}]
output FoundationMGIdOut array = [for name in mgNames: '${name}${pseudoRootMGName}']
output pseudoRootIdOut string = pseudoRootMGAlias.id
