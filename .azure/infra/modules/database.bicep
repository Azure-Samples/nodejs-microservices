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
// Resource-specific parameters
// ---------------------------------------------------------------------------

// TODO: tier

// @description('Specify the database type')
// @allowed([
//   'NoSQL'
//   'MongoDB'
//   'PostgreSQL'
// ])
// param databaseType string = 'NoSQL'

// Resource-specific parameters
// param databases array = []
// param collections array = []

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Cosmos DB
// https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts?pivots=deployment-language-bicep
resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: 'db-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    // enableMultipleWriteLocations: false
    // enableFreeTier: false
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        // isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
      }
    }
  }
}

// resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
//   parent: cosmosDb
//   name: '${projectName}-db'
//   properties: {
//     resource: {
//       id: '${projectName}-db'
//     }
//   }

// ---------------------------------------------------------------------------
// Secrets
// ---------------------------------------------------------------------------

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'

//   resource databaseConnectionString 'secrets' = {
//     name: 'databaseConnectionString'
//     properties: {
//       value: cosmosDb.listConnectionStrings().connectionStrings[0].connectionString
//     }
//   }
// }

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output databaseName string = cosmosDb.name
