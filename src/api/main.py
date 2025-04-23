import os
from azure.ai.projects.aio import AIProjectClient
from azure.ai.projects.models import (
    Agent,
    AgentThread,
    AsyncFunctionTool,
    AsyncToolSet,
    BingGroundingTool
)
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
from fastapi import FastAPI
from utilities.utilities import Utilities
from organization_data import OrganizationData

load_dotenv()
app = FastAPI()

# Constants
AGENT_NAME = "Analytic Agent"
API_DEPLOYMENT_NAME = os.getenv("MODEL_DEPLOYMENT_NAME")
PROJECT_CONNECTION_STRING = os.getenv("PROJECT_CONNECTION_STRING")
BING_CONNECTION_NAME = os.getenv("BING_CONNECTION_NAME")
INSTRUCTION_FILE = "instructions/function_calling.txt"
TEMPERATURE = 0.1

utilities = Utilities()
organization_data = OrganizationData(utilities)
project_client = AIProjectClient.from_connection_string(
    credential=DefaultAzureCredential(),
    conn_str=PROJECT_CONNECTION_STRING,
)

# Helper Functions
def prepare_instructions(query: str, database_schema: str) -> str:
    """Prepare instructions by replacing placeholders."""
    instructions = utilities.load_instructions(INSTRUCTION_FILE)
    instructions = instructions.replace("{organization}", query)
    return instructions.replace("{database_schema_string}", database_schema)

async def initialize_agent_and_thread() -> tuple[Agent, AgentThread]:
    """Initialize the agent and thread."""
    agent = await project_client.agents.create_agent(
        model=API_DEPLOYMENT_NAME,
        name=AGENT_NAME,
        instructions="You are a helpful agent that can analyze the organization data and provide insights.",
        temperature=TEMPERATURE,
    )
    thread = await project_client.agents.create_thread()
    return agent, thread

@app.get("/analyze")
async def analyze(query: str):
    try:
        # Initialize the agent and thread
        agent, thread = await initialize_agent_and_thread()

        # Connect to the database
        await organization_data.connect()
        database_schema = await organization_data.get_database_info()

        # Prepare instructions
        instructions = prepare_instructions(query, database_schema)
        print(instructions)
        # Create a message
        message = await project_client.agents.create_message(
            thread_id=thread.id,
            role="user",
            content=instructions,
        )

        # Run the agent
        toolset = AsyncToolSet()
        toolset.add(AsyncFunctionTool({organization_data.async_fetch_organization_data_using_sqlite_query}))

        # Add the Bing grounding tool
        bing_connection = await project_client.connections.get(connection_name=BING_CONNECTION_NAME)
        bing_grounding = BingGroundingTool(connection_id=bing_connection.id)
        print(f"Using Bing connection: {bing_connection.id}")
        toolset.add(bing_grounding)
        
        run = await project_client.agents.create_and_process_run(
            thread_id=thread.id, agent_id=agent.id, toolset=toolset
        )

        if run.status == "failed":
            return {"error": run.last_error}

        # Get messages from the thread
        messages = await project_client.agents.list_messages(thread_id=thread.id)
        return {"response": messages.data[0].content[0].text.value}

    except Exception as e:
        return {"error": str(e)}

    finally:
        await organization_data.close()
