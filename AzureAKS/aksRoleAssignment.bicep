param acrName string
param aksKubeletId string
param roleAcrPull string

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: acrName
}

resource AssignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, acrName, aksKubeletId, 'AssignAcrPullToAks')       // want consistent GUID on each run
  scope: acr
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: aksKubeletId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleAcrPull
  }
}
