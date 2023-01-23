//AKS

@description('the name of the Managed Cluster resource.')
param clusterName string = ''

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will appply the default disk size foir that agentVMSize')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('the number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('the size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublickey string

resource aks 'Microsoft.ContainerService/managedClusters@2022-10-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublickey
          }
        ]
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn