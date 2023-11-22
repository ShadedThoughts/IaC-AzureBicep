targetScope = 'subscription'

resource azResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'bicep-iac-rg'
  location: 'uksouth'
}
