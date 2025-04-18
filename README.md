# Overview

## Prerequisites

- Docker (Desktop or Engine) is installed so that you can run the project using a devcontainer.
- Azure subscription with permissions to create resources and assign roles.

## Infrastructure

```bash
# Login to Azure
az login

#navigate to the infrastructure directory
cd infrastructure

# run the deployment script
. ./deploy.sh
```

The `infrastructure/deploy.sh` script automates the deployment of Azure resources and performs several post-deployment tasks.

1. **Resource Group Creation**:
   - Creates a resource group named `rg-agent-vanalyst` in the `eastus` region.

1. **Azure Resource Deployment**:
   - Deploys resources defined in the `main.bicep` file using the Azure CLI. Parameters like `aiHubName`, `aiProjectName`, `modelName`, and others are passed to customize the deployment.
   - The deployment output is saved to a file named `output.json`.

1. **Post-Deployment Configuration**:
   - Extracts deployment outputs (e.g., `aiProjectName`, `resourceGroupName`, `subscriptionId`) from `output.json`.
   - Retrieves the `discovery_url` of the deployed Azure Machine Learning workspace and processes it to generate a `PROJECT_CONNECTION_STRING`.

1. **Environment File Setup**:
   - Writes the `PROJECT_CONNECTION_STRING` and other configuration values to a `.env` file for a Python project.

1. **Role Assignment**:
   - Assigns the "Data Scientist" role to the current user for the created resource group, enabling necessary permissions.

1. **Cleanup**:
   - Deletes the `output.json` file after processing.

This script streamlines the deployment and configuration process, ensuring all necessary resources and settings are prepared for the project. The provisioned resources include:

- Azure AI Services (which includes Azure OpenAI, Azure AI Agent Service, Azure AI Search and more)
- Azure Storage Account
- Azure AI hub
- Azure AI project

![azure-resources](./docs/assets/azure-resources.png)


