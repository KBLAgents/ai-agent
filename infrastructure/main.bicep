// Execute this main file to deploy Azure AI Foundry resources in the basic security configuration

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the AI resource and used to derive name of dependent resources.')
param aiHubName string = 'standard-hub'

@description('Friendly name for your Azure AI resource')
param aiHubFriendlyName string = 'Agents standard hub resource'

@description('Description of your Azure AI resource dispayed in Azure AI Foundry')
param aiHubDescription string = 'A standard hub resource required for the agent setup.'

@description('Name for the project')
param aiProjectName string = 'standard-project'

@description('Friendly name for your Azure AI resource')
param aiProjectFriendlyName string = 'Agents standard project resource'

@description('Description of your Azure AI resource dispayed in Azure AI Foundry')
param aiProjectDescription string = 'A standard project resource required for the agent setup.'

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Model name for deployment')
param modelName string = 'gpt-4o'

@description('Model format for deployment')
param modelFormat string = 'OpenAI'

@description('Model version for deployment')
param modelVersion string = '2024-08-06'

@description('Model deployment SKU name')
param modelSkuName string = 'GlobalStandard'

@description('Model deployment capacity')
param modelCapacity int = 200

@description('Model deployment location. If you want to deploy an Azure AI resource/model in different location than the rest of the resources created.')
param modelLocation string = 'westus'

// Variables
var name = toLower('${aiHubName}')
var projectName = toLower('${aiProjectName}')

@description('Name of the storage account')
param storageName string = 'agentservicestorage'

@description('Name of the Azure AI Services account')
param aiServicesName string = 'agent-ai-services'

// Create a short, unique suffix, that will be unique to each resource group
// var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)
param deploymentTimestamp string = utcNow('yyyyMMddHHmmss')
var uniqueSuffix = substring(uniqueString('${resourceGroup().id}-${deploymentTimestamp}'), 0, 4)

// Dependent resources for the Azure Machine Learning workspace
module aiDependencies 'modules-basic-keys/basic-dependent-resources-keys.bicep' = {
  name: 'dependencies-${name}-${uniqueSuffix}-deployment'
  params: {
    aiServicesName: '${aiServicesName}-${uniqueSuffix}'
    storageName: '${storageName}${uniqueSuffix}'
    location: location
    tags: tags

     // Model deployment parameters
     modelName: modelName
     modelFormat: modelFormat
     modelVersion: modelVersion
     modelSkuName: modelSkuName
     modelCapacity: modelCapacity
     modelLocation: modelLocation
  }
}

module aiHub 'modules-basic-keys/basic-ai-hub-keys.bicep' = {
  name: 'ai-${name}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiHubName: 'ai-${name}-${uniqueSuffix}'
    aiHubFriendlyName: aiHubFriendlyName
    aiHubDescription: aiHubDescription
    location: location
    tags: tags

    // dependent resources
    modelLocation: modelLocation
    storageAccountId: aiDependencies.outputs.storageId
    aiServicesId: aiDependencies.outputs.aiservicesID
    aiServicesTarget: aiDependencies.outputs.aiservicesTarget
  }
}

module aiProject 'modules-basic-keys/basic-ai-project-keys.bicep' = {
  name: 'ai-${projectName}-${uniqueSuffix}-deployment'
  params: {
    // workspace organization
    aiProjectName: 'ai-${projectName}-${uniqueSuffix}'
    aiProjectFriendlyName: aiProjectFriendlyName
    aiProjectDescription: aiProjectDescription
    location: location
    tags: tags

    // dependent resources
    aiHubId: aiHub.outputs.aiHubID
  }
}


// Outputs
output subscriptionId string = subscription().subscriptionId
output resourceGroupName string = resourceGroup().name
output aiProjectName string = 'ai-${projectName}-${uniqueSuffix}'
