# AI-Agent Project

## Overview
This repository contains sample code for building an AI agent using Azure services. The purpose of the AI agent is to analyze and summarize organizational data based on a provided organization name.

The project leverages **Azure AI Services**, **FastAPI**, and other cloud-native technologies to deploy, run, and test the AI workflows.

---

## Project Structure

Below is the project structure for the **AI-Agent**, with descriptions of key folders and files:
| **Path**                       | **Description**                                                               |
|--------------------------------|-------------------------------------------------------------------------------|
| `.devcontainer/`               | DevContainer configuration for remote development                             |
| ├── `devcontainer.json`        | Main configuration for setting up the container environment                   |
| ├── `Dockerfile`               | Custom Dockerfile with specific dependencies                                  |
| `.vscode/`                     | Visual Studio Code workspace settings                                         |
| ├── `launch.json`              | Debug/Launch configuration                                                    |
| ├── `settings.json`            | Workspace-specific settings for easy configuration                            |
| ├── `tasks.json`               | Tasks for automated workflows                                                 |
| `data/`                        | Placeholder directory for additional datasets                                 |
| `docs/`                        | Documentation assets                                                          |
| ├── `assets/`                  | Image resources and additional docs                                           |
| ├── `spike/`                   | Docs used in spike experiments                                                |
| `infrastructure/`              | Azure infrastructure deployment scripts                                       |
| ├── `modules-basic-keys/`      | Bicep module definitions for resources                                        |
| │ ├── `basic-ai-hub-keys.bicep` | AI Hub configuration                                                         |
| │ ├── `basic-ai-project-keys.bicep` | AI Project configuration                                                 |
| │ ├── `basic-dependent-resources-keys.bicep` | Dependencies for the AI environment                             |
| ├── `deploy.sh`                | Bash script for deploying resources on Azure                                  |
| ├── `main.bicep`               | Main deployment file for resource orchestration                               |
| ├── `output.json`              | JSON output from a successful deployment                                      |
| ├── `sample.env`               | Sample environment variables file                                             |
| `src/api/`                     | Source code directory                                                         |
| ├── `__pycache__/`             | Auto-generated cache files for Python                                         |
| ├── `database/`                | SQLite database scripts and files                                             |
| │ ├── `generate_sql.py`        | Script to generate and populate the database                                  |
| │ ├── `organization_entities.sql` | SQL schema for entity definitions                                          |
| ├── `instructions/`            | Instructions and notes regarding API functionality                            |
| │ ├── `function_calling.txt`   | Notes and ideas for functionality                                             |
| ├── `utilities/`               | Utility functions for the API                                                 |
| │ ├── `utilities.py`           | Helper functions for encoding, formatting, etc.                               |
| ├── `.env`                     | Environment configuration file                                                |
| ├── `main.py`                  | Entry point for FastAPI application                                           |
| ├── `organization_data.py`     | Core logic for processing organization data                                   |
| ├── `terminal_colors.py`       | Terminal color settings for output formatting                                 |
| ├── `README.md`                | Documentation for the API                                                     |
| `.gitignore`                   | Git ignore file                                                               |
| `LICENSE`                      | License file                                                                  |
| `README.md`                    | Documentation for the project                                                 |
| `requirements.txt`             | Python dependency file                                                        |


---

## Features
1. Summarizes and analyzes **organizational data**.
2. Infrastructure-as-code via **Azure Bicep** and deployable with scripts.
3. API built with **FastAPI**, providing endpoints like `GET /analyze`.
4. Uses **Docker** with a DevContainer setup to simplify development environments.
5. Provides self-documenting APIs via **Swagger UI** (`http://127.0.0.1:8000/docs`).

---

## Requirements
Before starting, ensure you have:
- **Docker** (Required for DevContainer)
    - Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- **Azure subscription** with permissions to create resources and assign roles.

The following are installed in the DevContainer:
- **Python 3.11+**
    - Download from [python.org](https://www.python.org/downloads/).
- **Azure CLI**
    - Follow instructions on [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
- **SQLite**
    - Download SQLite tools from [sqlite.org](https://www.sqlite.org/download.html) for manual database management.

---

## Setup Instructions

### 1. Clone the repository
```bash
git clone <repo-url>
cd ai-agent
```

### 3. Provision the Infrastructure
#### Step 1: Login to Azure

```bash
# navigate to the infrastructure directory
az login --tenant <your-tenant-id>

# Verify that you are logged in to the correct subscription
az account show
```
#### Step 2: Deploy the Azure resources

```bash
# navigate to the infrastructure directory
cd infrastructure

# copy and rename sample.env to .env
cp sample.env .env
# you can update these variable names if you want.

# run the deployment script
. ./deploy.sh
```

The `infrastructure/deploy.sh` script automates the deployment of Azure resources and performs several post-deployment tasks, ensuring all necessary resources and settings are prepared for the project. 

1. **Azure Authentication**
   - Checks `az login` status and prompts for login if needed.

1. **Resource Group Creation**:
   - Creates a resource group named `rg-agent-analyst` in the `westus` region.

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

The provisioned resources include:

- [Azure AI Services](https://learn.microsoft.com/en-us/azure/ai-services/what-are-ai-services) (includes Azure OpenAI, Azure AI Agent Service, Azure AI Search and more)
- [Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Azure AI hub](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/create-azure-ai-resource?tabs=portal)
- [Azure AI project](https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/create-projects?tabs=ai-studio)

![azure-resources](./docs/assets/azure-resources.png)


## Run locally

1. Confirm the `src/api/.env` has been created successfully and the `PROJECT_CONNECTION_STRING` is populated referencing the newly created resources.

1. Create the sqlite database with organization data based on `src/api/database/organization_entities.sql` by using the Command Palette (Ctrl+Shift+P on Windows, ⌘P on Mac), selecting `Tasks: Run Build Task`, and then the `Generate database` task or by running the following commands in the terminal:

   ```bash
   # navigate to the database directory
   cd ../src/api/database

   # generate database
   python generate_sql.py

   # confirm the database has been created (473 records)
   sqlite3 /workspaces/ai-agent/src/api/database/organizations.db "SELECT COUNT(*) FROM organizations"
   ```

1. Run the Analyst Agent API by using the Command Palette (Ctrl+Shift+P on Windows, ⌘P on Mac), selecting `Tasks: Run Build Task`, and then the `Run API` task or by running the following commands in the terminal:

    ```bash
    # navigate back to the api directory
    cd ..

    # run the API 
    uvicorn main:app --reload
    ```

    The API will load on http://127.0.0.1:8000/docs.

    Try out the GET /analyze endpoint by setting the query to any Fotune 500 company name or stock ticker symbol (e.g., Microsoft or MSFT).

    Alternatively, you can use curl:
    ```bash
    curl -X 'GET' 'http://127.0.0.1:8000/analyze?query=MSFT' -H 'accept: application/json'
    ```

    The response will be a JSON object containing the organization data, such as:
    ```json
    {
    "name": "Microsoft",
    "ticker": "MSFT",
    "industry": "Computer Software",
    "website": "https://microsoft.com",
    "headquaters": "Redmond, Washington",
    "employees": "221,000",
    "ceo": "Satya Nadella"
    }
    ```
---

## Troubleshooting

1. SQLite Database Error (`unable to open database file`):
    - Use the absolute path for `organizations.db`, for example:
      ```bash
      sqlite3 '/workspaces/ai-agent/src/api/database/organizations.db' "SELECT * FROM organizations;"
      ```

1. Azure Role Assignment Failed during deployment:
    - Ensure you have the necessary permissions to assign roles in Azure.
    - Manually assign the "Data Scientist" role:
      ```bash
      az role assignment create --role "Data Scientist" --assignee "<objectId>" --scope "/subscriptions/<subId>/resourceGroups/rg-agent-analyst"
      ```
---

## Contributing

1. Fork the repository and create a feature branch.
2. Include appropriate tests for all new features or changes.
3. Submit a pull request after testing thoroughly.

---

## License
This project is licensed under the **MIT License**.

---