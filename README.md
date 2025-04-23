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
| ├── `devcontainer.json`         | Main configuration for setting up the container environment                   |
| ├── `Dockerfile`                | Custom Dockerfile with specific dependencies                                  |
| `.vscode/`                     | Visual Studio Code workspace settings                                         |
| ├── `settings.json`             | Workspace-specific settings for easy configuration                           |
| `data/`                        | Placeholder directory for additional datasets                                 |
| `docs/`                        | Documentation assets                                                         |
| ├── `assets/`                  | Image resources and additional docs                                          |
| ├── `.gitkeep`                 | Ensures folder existence in Git                                              |
| `infrastructure/`              | Azure infrastructure deployment scripts                                      |
| ├── `modules-basic-keys/`      | Bicep module definitions for resources                                        |
| │ ├── `basic-ai-hub-keys.bicep` | AI Hub configuration                                                        |
| │ ├── `basic-ai-project-keys.bicep` | AI Project configuration                                               |
| │ ├── `basic-dependent-resources-keys.bicep` | Dependencies for the AI environment                              |
| ├── `deploy.sh`                | Bash script for deploying resources on Azure                                 |
| ├── `main.bicep`               | Main deployment file for resource orchestration                              |
| ├── `output.json`              | JSON output from a successful deployment                                     |
| `src/api/`                     | Source code directory                                                        |
| ├── `__pycache__/`             | Auto-generated cache files for Python                                        |
| ├── `database/`                | SQLite database scripts and files                                            |
| │ ├── `generate_sql.py`        | Script to generate and populate the database                                 |
| │ ├── `organization_entities.sql` | SQL schema for entity definitions                                         |
| │ ├── `organizations.db`       | SQLite database file                                                        |
| ├── `instructions/`            | Instructions and notes regarding API functionality                          |
| │ ├── `function_calling.txt`   | Notes and ideas for functionality                                            |
| ├── `utilities/`               | Utility functions for the API                                                |
| │ ├── `utilities.py`           | Helper functions for encoding, formatting, etc.                              |
| ├── `.env`                     | Environment configuration file                                               |
| ├── `main.py`                  | Entry point for FastAPI application                                          |
| ├── `organization_data.py`     | Core logic for processing organization data                                  |
| ├── `README.md`                | Documentation for the API                                                    |
| `.gitignore`                   | Git ignore file                                                             |
| `LICENSE`                      | License file                                                                |
| `README.md`                    | Documentation for the project                                                |
| `requirements.txt`             | Python dependency file                                                      |


---

## Features
1. Summarizes and analyzes **organizational data**.
2. Infrastructure-as-code via **Azure Bicep** and deployable with scripts.
3. API built with **FastAPI**, providing endpoints like `GET /analyze`.
4. Uses **Docker** with a DevContainer setup to simplify development environments.
5. Provides self-documenting APIs via **Swagger UI** (`http://127.0.0.1:8000/docs`).

---

## Requirements
Before starting, ensure you have the following installed:
- **Python 3.11+**
    - Download from [python.org](https://www.python.org/downloads/).
- **Azure CLI**
    - Follow instructions on [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Docker** (Optional for DevContainers)
    - Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- **SQLite**
    - Download SQLite tools from [sqlite.org](https://www.sqlite.org/download.html) for manual database management.

---

## Setup Instructions

### 1. Clone the repository
```bash
git clone <repo-url>
cd ai-agent
```
### 2. Install Dependencies
1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
```
2. Install Python dependencies from `requirements.txt`:
```bash
pip install -r requirements.txt
```
### 3. Configure the Infrastructure
#### Step 1: Login to Azure
- Connect to your Azure account:
```bash
az login
```
- Verify that you are logged in to the correct subscription:
```bash
az account show
```
#### Step 2: Deploy the Azure resources
1. Navigate to the `infrastructure` directory:
```bash
cd infrastructure
```
2. Run the deployment script:
```bash
./deploy.sh
```

- The script will:
   - Create a resource group `rg-agent-analyst`.
   - Deploy Azure resources defined in `main.bicep`.
   - Output configuration details to `output.json` .
   - Generate a `.env` file for the FastAPI backend in `src/api` with variables like `PROJECT_CONNECTION_STRING`.
### 4. Generating `PROJECT_CONNECTION_STRING`
The `PROJECT_CONNECTION_STRING` is required for the FastAPI application and should reference the resources deployed on Azure.

#### Steps to Generate:
1. Navigate to the Azure portal to locate the following values:
    - **AI Hub Name (`aiHubName`)**: Found in the resource group under Azure AI Foundry.
    - **AI Project Name (`aiProjectName`)**: Found in the Azure AI Hub as part of the deployed resources.
    - **Model Name (`modelName`)**: The name of the deployed AI model (e.g., `gpt-4o`).
    - **Endpoint (`discovery_url`)**: This can be found in the Azure portal by selecting the deployed AI workspace. Example URL: `https://<resource-name>.openai.azure.com/`.

2. Combine these values into the following format:
    ```plaintext
    <HostName>;<SubscriptionId>;<ResourceGroupName>;<AIProjectName>
    ```
    Example:
    ```plaintext
    https://agent-analyst.openai.azure.com;78fe4846-8b13-459a-8797-898cfb7d0c88;rg-agent-analyst;ai-agent-project
    ```

3. Save the string in the `.env` file located in `src/api`:
    ```plaintext
    PROJECT_CONNECTION_STRING="<connection_string>"
    MODEL_DEPLOYMENT_NAME="gpt-4o"
    ```
---

### 5. Initialize the SQLite Database

1. Navigate to the `src/api/database` directory:
    ```bash
    cd src/api/database
    ```

2. Populate the database by running the provided script:
    ```bash
    python generate_sql.py
    ```

3. Verify the database contents:
    ```bash
    sqlite3 organizations.db "SELECT COUNT(*) FROM organizations;"
    ```
---

### 6. Run the FastAPI Application Locally

1. Navigate to the `src/api` directory:
    ```bash
    cd src/api
    ```

2. Start the FastAPI development server:
    ```bash
    uvicorn main:app --reload
    ```

3. Open the Swagger UI in your browser:
    ```plaintext
    http://127.0.0.1:8000/docs
    ```

4. Test the `GET /analyze` endpoint:
    - Use Swagger's "Try It Out" feature.
    - Provide a query string for a company name like `Omni Labs`.
    - Verify the JSON response, for example:
      ```json
      {
        "organization": "Omni Labs",
        "summary": "Omni Labs is a leader in AI solutions.",
        "analysis": "Focused on AI-driven robotics."
      }
      ```
---

## Troubleshooting

### Common Issues

1. **ModuleNotFoundError (e.g., azure.ai.projects)**:
    - Ensure Azure SDK modules are installed and updated:
      ```bash
      pip install azure-ai
      pip install --upgrade azure
      ```

2. **SQLite Database Error (`unable to open database file`)**:
    - Use the absolute path for `organizations.db`, for example:
      ```bash
      sqlite3 'C:/Users/username/ai-agent/src/api/database/organizations.db' "SELECT * FROM organizations;"
      ```

3. **Azure Role Assignment Failed**:
    - Manually assign the "Data Scientist" role:
      ```bash
      az role assignment create --role "Data Scientist" --assignee "<objectId>" --scope "/subscriptions/<subId>/resourceGroups/rg-agent-analyst"
      ```

4. **FastAPI Not Starting (`main.py` not found)**:
    - Ensure you're running from the correct directory:
      ```bash
      uvicorn main:app --reload
      ```
---
## Contributing
1. Fork the repository and create a feature branch.
2. Include appropriate tests for all new features or changes.
3. Submit a pull request after testing thoroughly.
---
## License
This project is licensed under the **MIT License**.

