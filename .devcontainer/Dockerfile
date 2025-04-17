FROM mcr.microsoft.com/devcontainers/python:3.13-bullseye

RUN python -m pip install --upgrade pip

COPY ../src/api/requirements.txt .

# Create and activate Virtual Environment in the api folder
RUN python -m venv ../src/api/ && source ../src/api/.venv/bin/activate

#Activate the vis
RUN pip install -r requirements.txt

