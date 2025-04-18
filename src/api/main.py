import os
from typing import Union
from azure.ai.projects.aio import AIProjectClient
from azure.ai.projects.models import CodeInterpreterTool, Agent, AgentThread
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
from fastapi import FastAPI

from contracts.analytics_contract import AnalyticsResponse
from utilities.utitlities import Utilities

load_dotenv()
app = FastAPI()

AGENT_NAME = "Analytic Agent"
API_DEPLOYMENT_NAME = os.getenv("MODEL_DEPLOYMENT_NAME")
PROJECT_CONNECTION_STRING = os.getenv("PROJECT_CONNECTION_STRING")
BING_CONNECTION_NAME = os.getenv("BING_CONNECTION_NAME")
INSTRUCTION_FILE = "instructions/instructions.txt"
TEMPERATURE = 0.1

utilities = Utilities()

INSTRUCTIONS = utilities.load_instructions(INSTRUCTION_FILE)
project_client = AIProjectClient.from_connection_string(
    credential=DefaultAzureCredential(),
    conn_str=PROJECT_CONNECTION_STRING,
)


async def initialize_agent() -> tuple[Agent, AgentThread]:
    agent = await project_client.agents.create_agent(
        model=API_DEPLOYMENT_NAME,
        name=AGENT_NAME,
        instructions="You are a helpful agent that can analyze the company and provide insights.",
        temperature=TEMPERATURE,
    )
    print(f"Created agent, agent ID: {agent.id}")

    # Create a thread
    thread = await project_client.agents.create_thread()
    print(f"Created thread, thread ID: {thread.id}")
    return agent, thread


@app.get("/analyze")
async def analyze(query: str):

    agent, thread = await initialize_agent()

    if not agent or not thread:
        print(
            f"Initialization failed. Agent ID: {agent.id}, Thread ID: {thread.id}")
        print("Exiting...")
        return
    instructions = INSTRUCTIONS.replace("{company}", query)
    # Create a message
    message = await project_client.agents.create_message(
        thread_id=thread.id,
        role="user",
        content=instructions,
    )
    print(f"Created message, message ID: {message.id}")

    # Run the agent
    run = await project_client.agents.create_and_process_run(thread_id=thread.id, agent_id=agent.id)
    print(f"Run finished with status: {run.status}")

    if run.status == "failed":
        # Check if you got "Rate limit is exceeded.", then you want to get more quota
        print(f"Run failed: {run.last_error}")

    # Get messages from the thread
    messages = await project_client.agents.list_messages(thread_id=thread.id)

    print(f"Messages: {messages.data[0].content[0].text.value}")
    return ({messages.data[0].content[0].text.value})
