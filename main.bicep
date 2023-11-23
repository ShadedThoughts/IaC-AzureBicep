// Using parameters and parameter decorators
param storageAccountName string = 'StgOslo1001'

@allowed([
  'uksouth'
  'westeurope'
  'northeurope'
])
param storageAccountLocation string = 'uksouth'

@secure()
param securePassword string

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: storageAccountLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Cool'
  }
}

// Output data from resource created. This can also be used as input for another resource
output stgout string = stg.properties.primaryEndpoints.blob
