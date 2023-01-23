//Create SSH

@description('GeoLocation of the SSH Key')
param sshLocation string = resourceGroup().location
@description('Name of the SSH Key')
param sshKeyName string

resource symbolicname 'Microsoft.Compute/sshPublicKeys@2022-08-01' = {
  name: sshKeyName
  location: sshLocation
}
