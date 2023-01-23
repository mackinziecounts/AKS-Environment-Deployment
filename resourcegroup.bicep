//create a resource group
targetScope = 'subscription'

param rgName string
param rgLocation string

var rgNameVar = '${rgName}${rgLocation}'

resource customrg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgNameVar
  location: rgLocation
}
output rgOutput string = customrg.id
output rgNameOutput string = customrg.name 
