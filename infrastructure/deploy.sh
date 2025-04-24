#!/bin/bash

set -euo pipefail



# Check for required tools
for cmd in az jq sed tee; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command '$cmd' not found. Please install it before running this script." >&2
    exit 2
  fi
done

# Log file for all output
LOG_FILE="/tmp/deploy_azure.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Define resource group parameters
RG_NAME="rg-agent-analyst"
RG_LOCATION="westus"
MODEL_NAME="gpt-4o"
AI_HUB_NAME="agent-wksp"
AI_PROJECT_NAME="agent-analyst"
AI_PROJECT_FRIENDLY_NAME="Agent-Service-analyst"
STORAGE_NAME="agentservicestorage"
AI_SERVICES_NAME="agent-analyst"
MODEL_CAPACITY=50

# Validate required environment variables and parameters
required_vars=(RG_NAME RG_LOCATION MODEL_NAME AI_HUB_NAME AI_PROJECT_NAME AI_PROJECT_FRIENDLY_NAME STORAGE_NAME AI_SERVICES_NAME MODEL_CAPACITY)
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Required variable $var is not set or empty." >&2
    exit 3
  fi
  # Print progress
  echo "Using $var='${!var}'"
done

error_exit() {
  echo "Error on line $1: $2" >&2
  # Clean up output.json if it exists
  echo "Cleaning up output.json..."
  [ -f output.json ] && rm -f output.json
  exit 1
}
trap 'error_exit $LINENO "$BASH_COMMAND"' ERR

echo "Deploying the Azure resources..."

# Check Azure CLI login status
if ! az account show > /dev/null 2>&1; then
  echo "You are not logged in to Azure CLI. Please log in."
  az login || { echo "Azure login failed." >&2; exit 4; }
fi

# Create the resource group
az group create --name "$RG_NAME" --location "$RG_LOCATION" || error_exit $LINENO "Failed to create resource group"

# Deploy the Azure resources and save output to JSON
az deployment group create \
  --resource-group "$RG_NAME" \
  --template-file main.bicep \
  --parameters aiHubName="$AI_HUB_NAME" \
      aiProjectName="$AI_PROJECT_NAME" \
      aiProjectFriendlyName="$AI_PROJECT_FRIENDLY_NAME" \
      storageName="$STORAGE_NAME" \
      aiServicesName="$AI_SERVICES_NAME" \
      modelName="$MODEL_NAME" \
      modelCapacity="$MODEL_CAPACITY" \
      modelLocation="$RG_LOCATION" > output.json || error_exit $LINENO "Azure deployment failed"

# Check command outputs before using them
if [ -f output.json ]; then
  AI_PROJECT_NAME=$(jq -r '.properties.outputs.aiProjectName.value' output.json) || error_exit $LINENO "Failed to parse aiProjectName"
  if [ -z "$AI_PROJECT_NAME" ] || [ "$AI_PROJECT_NAME" = "null" ]; then error_exit $LINENO "aiProjectName is empty or null"; fi
  RESOURCE_GROUP_NAME=$(jq -r '.properties.outputs.resourceGroupName.value' output.json) || error_exit $LINENO "Failed to parse resourceGroupName"
  if [ -z "$RESOURCE_GROUP_NAME" ] || [ "$RESOURCE_GROUP_NAME" = "null" ]; then error_exit $LINENO "resourceGroupName is empty or null"; fi
  SUBSCRIPTION_ID=$(jq -r '.properties.outputs.subscriptionId.value' output.json) || error_exit $LINENO "Failed to parse subscriptionId"
  if [ -z "$SUBSCRIPTION_ID" ] || [ "$SUBSCRIPTION_ID" = "null" ]; then error_exit $LINENO "subscriptionId is empty or null"; fi

  DISCOVERY_URL=$(az ml workspace show -n "$AI_PROJECT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query discovery_url -o tsv) || error_exit $LINENO "Failed to get discovery_url"
  if [ -z "$DISCOVERY_URL" ]; then error_exit $LINENO "discovery_url is empty"; fi

  HOST_NAME=$(echo "$DISCOVERY_URL" | sed -e 's|^https://||' -e 's|/discovery$||') || error_exit $LINENO "Failed to parse HOST_NAME"
  if [ -z "$HOST_NAME" ]; then error_exit $LINENO "HOST_NAME is empty"; fi

  PROJECT_CONNECTION_STRING="\"$HOST_NAME;$SUBSCRIPTION_ID;$RESOURCE_GROUP_NAME;$AI_PROJECT_NAME\""
  ENV_FILE_PATH="../src/api/.env"

  [ -f "$ENV_FILE_PATH" ] && rm "$ENV_FILE_PATH" || true

  {
    echo "PROJECT_CONNECTION_STRING=$PROJECT_CONNECTION_STRING"
    echo "MODEL_DEPLOYMENT_NAME=\"$MODEL_NAME\""
  } > "$ENV_FILE_PATH" || error_exit $LINENO "Failed to write .env file"

  rm -f output.json || error_exit $LINENO "Failed to remove output.json"
else
  error_exit $LINENO "output.json not found."
fi

# Set Variables
subId=$(az account show --query id --output tsv) || error_exit $LINENO "Failed to get subscription id"
if [ -z "$subId" ]; then error_exit $LINENO "subId is empty"; fi
objectId=$(az ad signed-in-user show --query id -o tsv) || error_exit $LINENO "Failed to get user object id"
if [ -z "$objectId" ]; then error_exit $LINENO "objectId is empty"; fi

echo "Adding data scientist user role"

az role assignment create --role "f6c7c914-8db3-469d-8ca1-694a8f32e121" \
                          --assignee-object-id "$objectId" \
                          --scope "subscriptions/$subId/resourceGroups/$RG_NAME" \
                          --assignee-principal-type 'User' || error_exit $LINENO "User role assignment failed."

echo "User role assignment succeeded."