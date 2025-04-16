FROM mcr.microsoft.com/devcontainers/python:3.13-bullseye

RUN python -m pip install --upgrade pip

COPY ../src/api/requirements.txt .
RUN pip install -r requirements.txt

