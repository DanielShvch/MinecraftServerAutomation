from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
import subprocess
import os

app = FastAPI()

API_TOKEN = os.getenv("BAZINGA", "bazinga123")
security = HTTPBearer()

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != API_TOKEN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid or missing token"
        )

class NewServerInput(BaseModel):
    username: str
    version: str

class WhitelistInput(BaseModel):
    username: str
    ID: str

@app.post("/start-new-server/")
def new_minecraft(input_data: NewServerInput, _: HTTPAuthorizationCredentials = Depends(verify_token)):
    try:
        result = subprocess.run(
            ["/minecraft_automation/Scripts/new_server_for_api.sh", input_data.username, input_data.version],
            capture_output=True,
            text=True,
            check=True
        )
        return {
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip()
        }
    except subprocess.CalledProcessError as e:
        return {
            "error": "Script failed",
            "stdout": e.stdout.strip(),
            "stderr": e.stderr.strip(),
            "exception": str(e)
        }

@app.post("/add-to-whitelist/")
def add_whitelist(input_data: WhitelistInput, _: HTTPAuthorizationCredentials = Depends(verify_token)):
    try:
        whitelist_result = subprocess.run(
            ["python3", "/minecraft_automation/Scripts/add_whitelist.py", input_data.ID, input_data.username],
            capture_output=True,
            text=True,
            check=True
        )

        restart_result = subprocess.run(
            ["/minecraft_automation/Scripts/restart_server.sh", input_data.ID],
            capture_output=True,
            text=True,
            check=True
        )

        return {
            "white_stdout": whitelist_result.stdout.strip(),
            "restart_stdout": restart_result.stdout.strip(),
            "white_stderr": whitelist_result.stderr.strip(),
            "restart_stderr": restart_result.stderr.strip()
        }

    except subprocess.CalledProcessError as e:
        return {
            "error": "Script failed",
            "stdout": e.stdout.strip(),
            "stderr": e.stderr.strip(),
            "exception": str(e)
        }
