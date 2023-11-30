// Parameters and Decorators
param localAdminName string
param vnetName string
param subnetName string
param vmSku string = 'Standard_D4s_v4'
param vmOS string = '2019-Datacenter'
param vmLocation string

@secure()
param localAdminPassword string

var vmName = 'bicep-vm'
var defaultVmNicName = '${vmName}-nic'
var privateIPAllocationMethod = 'Dynamic'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource vmNic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: defaultVmNicName
  location: vmLocation
  dependsOn: [
    vnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: '${vnet.id}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: vmLocation
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

