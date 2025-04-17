from typing import Union

from fastapi import FastAPI

app = FastAPI()

@app.get("/chat")
async def home():
    return "Hello"

print("Hello")