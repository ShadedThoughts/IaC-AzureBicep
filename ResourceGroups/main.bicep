targetScope = 'subscription'

@allowed([
    'uksouth'
    'westeurope'
  ]
)
param location string
param resourceGrp string
param vnetName string
param subnetName string
param localAdminName string
param deployResourceGroup bool = true
param keyVaultSubscription string
param keyVaultResourceGroup string
param keyVaultName string
param secretName string

@secure()
param secretVersion string

// @secure()
// param localAdminPassword string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = if (deployResourceGroup) {
  name: resourceGrp
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultSubscription, keyVaultResourceGroup)
}

module vnet 'vnet-module.bicep' = {
  scope: rg
  name: 'virtualNetwork'
  params: {
    vnetLocation: location
    vnetName: vnetName
  }
}

module vm 'vm-module.bicep' = {
  scope: rg
  name: 'virtualMachine'
  params: {
    vmLocation: location
    localAdminName: localAdminName
    localAdminPassword: kv.getSecret(secretName, secretVersion)
    vnetName: vnetName
    subnetName: subnetName
  }
}
