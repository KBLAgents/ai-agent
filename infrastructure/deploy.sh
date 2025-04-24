#!/bin/bash

echo "Deploying the Azure resources..."

# Load environment variables from .env file
# set -a
source ".env"
# set +a

# Verify required variables are loaded
required_vars=(RG_NAME RG_LOCATION MODEL_NAME AI_HUB_NAME AI_PROJECT_NAME AI_PROJECT_FRIENDLY_NAME STORAGE_NAME AI_SERVICES_NAME MODEL_CAPACITY)
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set in .env file."
    exit 1
  fi
done

# Create the resource group
az group create --name "$RG_NAME" --location "$RG_LOCATION"

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
      modelLocation="$RG_LOCATION" > output.json

# Parse the JSON file manually using grep and sed
if [ -f output.json ]; then
  AI_PROJECT_NAME=$(jq -r '.properties.outputs.aiProjectName.value' output.json)
  RESOURCE_GROUP_NAME=$(jq -r '.properties.outputs.resourceGroupName.value' output.json)
  SUBSCRIPTION_ID=$(jq -r '.properties.outputs.subscriptionId.value' output.json)

  # Run the Azure CLI command to get discovery_url
  DISCOVERY_URL=$(az ml workspace show -n "$AI_PROJECT_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query discovery_url -o tsv)

  if [ -n "$DISCOVERY_URL" ]; then
    # Process the discovery_url to extract the HostName
    HOST_NAME=$(echo "$DISCOVERY_URL" | sed -e 's|^https://||' -e 's|/discovery$||')

    # Generate the PROJECT_CONNECTION_STRING
    PROJECT_CONNECTION_STRING="\"$HOST_NAME;$SUBSCRIPTION_ID;$RESOURCE_GROUP_NAME;$AI_PROJECT_NAME\""

    ENV_FILE_PATH="../src/api/.env"

    # Delete the file if it exists
    [ -f "$ENV_FILE_PATH" ] && rm "$ENV_FILE_PATH"

    # Write to the .env file
    {
      echo "PROJECT_CONNECTION_STRING=$PROJECT_CONNECTION_STRING"
      echo "MODEL_DEPLOYMENT_NAME=\"$MODEL_NAME\""
    } > "$ENV_FILE_PATH"

    # Delete the output.json file
    rm -f output.json
  else
    echo "Error: discovery_url not found."
  fi
else
  echo "Error: output.json not found."
fi

# Set Variables
subId=$(az account show --query id --output tsv)
objectId=$(az ad signed-in-user show --query id -o tsv)

#Adding data scientist role
echo "Adding data scientist user role"

az role assignment create --role "f6c7c914-8db3-469d-8ca1-694a8f32e121" \
                          --assignee-object-id "$objectId" \
                          --scope "subscriptions/$subId/resourceGroups/$RG_NAME" \
                          --assignee-principal-type 'User'

# Check if the command failed
if [ $? -ne 0 ]; then
    echo "User role assignment failed."
    exit 1
fi

echo "User role assignment succeeded."