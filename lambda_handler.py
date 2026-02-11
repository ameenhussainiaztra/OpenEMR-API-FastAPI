"""
AWS Lambda handler for FastAPI application using Mangum.
Mangum adapts ASGI applications (FastAPI) to work with AWS Lambda.
"""

from mangum import Mangum
from main import app

# Create Mangum handler - handles API Gateway HTTP API events
handler = Mangum(app, lifespan="off")
