//create a resource group
targetScope = 'subscription'
//rgName and rgLocation are supplied as variables through PowerShell
param rgName string
param rgLocation string
//rgName and rgLocation are concatenated together to create the complete name of the resource group
var rgNameVar = '${rgName}${rgLocation}'
//expected outcome 'aksWestUS'
resource customrg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgNameVar
  location: rgLocation
}
output rgOutput string = customrg.id
output rgNameOutput string = customrg.name 
