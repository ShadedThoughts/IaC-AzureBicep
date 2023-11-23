// Parameters and Decorators
param vnetName string = 'bicep-VNET'
param vnetLocation string = 'uksouth'
param subnetName string = 'frontEnd'

var vnetConfig = {
  vnetprefix: '10.0.0.0/16'
  subnet: {
    name: 'frontEnd'
    subnetPrefix: '10.0.1.0/24'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfig.vnetprefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: vnetConfig.subnet.subnetPrefix
        }
      }
    ]
  }
}
