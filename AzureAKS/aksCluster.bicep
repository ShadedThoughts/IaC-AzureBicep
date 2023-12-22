param location string = resourceGroup().location

@description('The size of the Virtual Machine.')
param agentVMSize string //= 'Standard_D2s_v3'

@description('The number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(100)
param agentCount int //= 3

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

// @description('User name for the Linux Virtual Machines.')
// param linuxAdminUsername string

// @description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
// param sshRSAPublicKey string

param aksClusterName string //= 'uohdaimaks'
param aksManagedIdentity string //= 'SystemAssigned'
param dnsPrefix string //= 'uohdaimaks'

@description('The type of operating system.')
@allowed([
  'Linux'
  'Windows'
])
param osType string //= 'Linux'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-09-01' = {
  name: aksClusterName
  location: location
  identity: {
    type: aksManagedIdentity
  }
  properties: {
    kubernetesVersion: '1.27.7'
    dnsPrefix: dnsPrefix
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: agentCount
        vmSize: agentVMSize
        osType: osType
        osDiskSizeGB: osDiskSizeGB
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]
    // linuxProfile: {
    //   adminUsername: linuxAdminUsername
    //   ssh: {
    //     publicKeys: [
    //       {
    //         keyData: sshRSAPublicKey
    //       }
    //     ]
    //   }
    // }
  }
}

output controlPlaneFQDN string = aksCluster.properties.fqdn
output aksKubeletId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
