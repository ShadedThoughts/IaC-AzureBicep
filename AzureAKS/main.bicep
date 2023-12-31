param location string = resourceGroup().location

// Parameters for AKS Cluster
param aksClusterName string
param agentCount int
param agentVMSize string
param aksManagedIdentity string
param dnsPrefix string
param osType string
param acrRG string

// Parameters for AKS Role Assignment
param acrName string
param builtInRoleType string


module aks './aksCluster.bicep' = {
  name: 'AksCluster'
  //scope: rg
  params: {
    aksClusterName: aksClusterName
    agentCount: agentCount
    agentVMSize: agentVMSize
    aksManagedIdentity: aksManagedIdentity
    dnsPrefix: dnsPrefix
    osType: osType
    location: location

  }
}

module rbac './aksRoleAssignment.bicep' = {
  name: 'AksRoleAssignments'
  scope: resourceGroup('${acrRG}')
  params: {
     acrName: acrName
     aksKubeletId: aks.outputs.aksKubeletId
     //roleAcrPull: roleAcrPull
     builtInRoleType: builtInRoleType
  }
}
