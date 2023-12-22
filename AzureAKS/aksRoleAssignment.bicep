param acrName string
param aksKubeletId string
//param roleAcrPull string

@allowed([
  'AcrPull'
  'AcrPush'
])
@description('Built-in role to assign')
param builtInRoleType string

var roleDefinitionId = {
  AcrPull: {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
  AcrPush: {
    id: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: acrName
}

// resource AssignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, aksKubeletId, 'AcrPull')       // want consistent GUID on each run
//   scope: acr
//   properties: {
//     description: 'Assign AcrPull role to AKS'
//     principalId: aksKubeletId
//     principalType: 'ServicePrincipal'
//     roleDefinitionId: roleAcrPull
//   }
// }

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aksKubeletId, roleDefinitionId[builtInRoleType].id)
  scope: acr
  properties: {
    description: 'Assign AcrPull role to AKS'
    roleDefinitionId: roleDefinitionId[builtInRoleType].id
    principalId: aksKubeletId
    principalType: 'ServicePrincipal'
  }
}
