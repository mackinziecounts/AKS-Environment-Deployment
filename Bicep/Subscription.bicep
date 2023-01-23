targetScope = 'managementGroup'

param subscriptionName string
param billingScope string

@allowed([
  'DevTest'
  'Production'])
param workloadParam string

resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: subscriptionName
  properties: {
    workload: workloadParam
    displayName: subscriptionName
    billingScope: billingScope
  }
}
output subId string = subscriptionAlias.id

