param location string = resourceGroup().location
@description('Prefix string to use with resources.')
param appNamePrefix string

//var cosmosDBAccountName = '${appNamePrefix}-cosmosdba'
var appInsightsName = '${appNamePrefix}-appinsights'
var workspaceName = '${appNamePrefix}-workspace'
var appServicePlanName = '${appNamePrefix}-appserviceplan'
var containerRegisteryName = format('{0}cr', replace(appNamePrefix, '-', ''))
var containerAppName = '${appNamePrefix}-containerapp'
var environmentName = '${appNamePrefix}-containerenv'
var appTags = {
  Name: 'Learning'
  Description: 'Used for learning purpose'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'Y1'
    capacity: 1
  }
  properties: {
    reserved: true
  }
  tags: appTags
}
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
resource appInsightsComponents 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
  tags: appTags
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: containerRegisteryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource managedEnvironments 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listLeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerapps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  tags: appTags
  
  properties: {
    configuration: {
      activeRevisionsMode: 'single'
      registries:[
        containerRegistry
      ]
    }
    template: {
      containers: 'containers'
      scale: {
        minReplicas: 0
      }
    }
    managedEnvironmentId: managedEnvironments.id
  }
}
