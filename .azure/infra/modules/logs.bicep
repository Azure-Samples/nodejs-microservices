// ---------------------------------------------------------------------------
// Common parameters for all modules
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string

@description('The Azure region where all resources will be created')
param location string = resourceGroup().location

@description('Tags for the resources')
param tags object = {}

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Log Analytics Workspace
// https://docs.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces?tabs=bicep
resource logsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'logs-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output logsWorkspaceName string = logsWorkspace.name
output logsWorkspaceCustomerId string = logsWorkspace.properties.customerId
