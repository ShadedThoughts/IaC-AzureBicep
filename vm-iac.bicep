// Parameters and Decorators
param localAdminName string
param vnetName string = 'bicep-VNET'
param vmSku string = 'Standard_D4s_v4'
param vmOS string = '2019-Datacenter'

@secure()
param localAdminPassword string

var defaultLocation = resourceGroup().location
var vmName = 'bicep-vm'
var defaultVmNicName = '${vmName}-nic'
var vnetConfig = {
  vnetprefix: '10.0.0.0/16'
  subnet: {
    name: 'frontEnd'
    subnetPrefix: '10.0.1.0/24'
  }
}
var privateIPAllocationMethod = 'Dynamic'

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: defaultLocation
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

resource vmNic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: defaultVmNicName
  location: defaultLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: '${vnet.id}/subnets/${vnetConfig.subnet.name}'
          }
        }
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: defaultLocation
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    osProfile: {
      computerName: vmName
      adminUsername: localAdminName
      adminPassword: localAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmOS
        version: 'latest'
      }
      osDisk: {
        //name: 'name'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}

