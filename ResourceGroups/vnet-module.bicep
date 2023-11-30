// Parameters and Decorators
param vnetName string
param vnetLocation string

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
        name: vnetConfig.subnet.name
        properties: {
          addressPrefix: vnetConfig.subnet.subnetPrefix
        }
      }
    ]
  }
}

output subnetName string = vnetConfig.subnet.name
output vnetId string = vnet.id
