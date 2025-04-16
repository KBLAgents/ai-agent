# Overview

This repo is a by-product of the workshop "Building LLM-Powered AI Agents with Azure AI Agent Service".The workshop is designed to help developers understand how to build LLM-powered AI agents using the Azure AI Agent Service and the original code and documentation can be found in:

- [Docs](https://microsoft.github.io/build-your-first-agent-with-azure-ai-agent-service-workshop/)
- [Repo](https://github.com/microsoft/build-your-first-agent-with-azure-ai-agent-service-workshop)
- [Related session](https://developer.microsoft.com/en-us/reactor/events/25312/)

## Virtual Analyst Agent

Imagine you are an analyst at Contoso, a multinational company that investors use to analyze market trends. You need to analyze company data to find trends, identify patterns, and make informed business decisions. To help you, Contoso has developed a conversational agent that can answer questions about your company data.

## What is an LLM-Powered AI Agent

An AI Agent is semi-autonomous software designed to achieve a given goal without requiring predefined steps or processes. Instead of following explicitly programmed instructions, the agent determines how to accomplish the task dynamically.

For example, if a user asks, "**Show the overview of company XYZ**", the app does not rely on predefined logic for this specific request. Instead, a Large Language Model (LLM) interprets the request, manages the conversation flow and context, and orchestrates the necessary actions to produce the desired data.

Unlike traditional applications, where developers define the logic and workflows to support business processes, AI Agents shift this responsibility to the LLM. In these systems, prompt engineering, clear instructions, and tool development are critical to ensuring the application performs as intended.

## What is the Azure AI Agent Service

The Azure AI Agent Service is a single-agent cloud service with accompanying SDKs. Developers can access SDKs for [Python](https://learn.microsoft.com/azure/ai-services/agents/quickstart?pivots=programming-language-python-azure).

The Azure AI Agent Service simplifies the creation of intelligent agents by offering built-in conversation state management and compatibility with various AI models. It provides a range of ready-to-use tools, including integrations with Fabric, SharePoint, Azure AI Search, and Azure Storage. The service also supports custom integrations through the Function Calling tool and enables RAG-style search capabilities with a built-in vector store for “file search” and semantic search features. Designed for scalability, it ensures smooth performance even under varying user loads.

Learn more about the Azure AI Agent Service in the [Azure AI Agent Service documentation](https://learn.microsoft.com/azure/ai-services/agents/concepts/agents){:target="_blank"}. In particular, read about the [components of agents](https://learn.microsoft.com/azure/ai-services/agents/concepts/agents#agents-components){:target="_blank"}.

## Prerequisites

1. Azure Subscription
1. Python 3.12 or later
1. Visual Studio Code with the Python extension installed.
1. azd CLI installed.

## Infrastructure

TBD

## Setup

1. Using a terminal window, create and activate a virtual environment:

    ```bash
    python -m venv .venv

    # on Windows
    source ./.venv/Scripts/activate

    # on MacOS/Linux
    source ./.venv/bin/activate
    ```

1. Install the required packages:

    ```bash
    pip install -r requirements.txt
    ```

1. Create a .env file based on the .env.sample file:

    ```bash
    cp .env.example .env
    ```

    and update the following

    ```text
    PROJECT_CONNECTION_STRING=<PROJECT_CONNECTION_STRING>
    BING_CONNECTION_NAME=<BING_CONNECTION_NAME>
    APP_INSIGHTS_INSTRUMENTATION_KEY=<APP_INSIGHTS_INSTRUMENTATION_KEY>
    ```

## Run the app

```bash
cd src/
python main.py
```
