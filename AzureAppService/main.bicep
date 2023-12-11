@description('Location of all resources')
param location string = resourceGroup().location

@description('WebApp name.')
@minLength(2)
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Allowed App Service Plan Pricing')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
])
param sku string

@description('Development Language of the App Service')
@allowed([
  '.net'
  'php'
  'node'
  'html'
])
param language string

@description('Optional Git Repo URL to deploy sample app to the App Service')
param repoUrl string = ''

var appServicePlanName = 'AppServicePlan-${webAppName}'
var gitRepoReference = {
  '.net': 'https://github.com/Azure-Samples/app-service-web-dotnet-get-started'
  node: 'https://github.com/Azure-Samples/nodejs-docs-hello-world'
  php: 'https://github.com/Azure-Samples/php-docs-hello-world'
  html: 'https://github.com/Azure-Samples/html-docs-hello-world'
}
var gitRepoUrl = (empty(repoUrl) ? gitRepoReference[language] : repoUrl)
var configReference = {
  '.net': {
    comments: '.Net app. No additional configuration needed.'
  }
  html: {
    comments: 'HTML app. No additional configuration needed.'
  }
  php: {
    phpVersion: '7.4'
  }
  node: {
    appSettings: [
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '12.15.0'
      }
    ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: union(configReference[language],{
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    })
  }
}

// resource gitsource 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
//   parent: webApp
//   name: 'web'
//   properties: {
//     repoUrl: gitRepoUrl
//     branch: 'master'
//     isManualIntegration: true
//   }
// }

output aspOut string = appServicePlan.id
output webAppOut string = webApp.properties.serverFarmId
