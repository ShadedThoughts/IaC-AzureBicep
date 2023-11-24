targetScope = 'subscription'

@allowed([
    'uksouth'
    'westeurope'
  ]
)
param location string = 'uksouth'
param vnetName string = 'bicep-VNET'
param subnetName string = 'frontEnd'
param localAdminName string = 'adminpc'
param deployResourceGroup bool = true
param keyVaultSubscription string = '031e997d-b908-4dd0-9dba-c440758aec29'
param keyVaultResourceGroup string = 'iac-rg-dev'
param secretName string = 'secretName'
param secretVersion string = '64a73bcbad2f453581f5f683bf30b8e2'

// @secure()
// param localAdminPassword string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = if (deployResourceGroup) {
  name: 'bicep-iac-rg'
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'iac-keyv-dev'
  scope: resourceGroup(keyVaultSubscription, keyVaultResourceGroup)
}

module vnet 'vnet-module.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    vnetLocation: location
    vnetName: vnetName
  }
}

module vm 'vm-module.bicep' = {
  scope: rg
  name: 'VM'
  params: {
    localAdminName: localAdminName
    localAdminPassword: kv.getSecret(secretName, secretVersion)
    vnetName: vnetName
    subnetName: subnetName
  }
}
