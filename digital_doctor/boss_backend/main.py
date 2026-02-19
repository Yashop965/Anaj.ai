from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
from typing import Optional

from model_engine import BossModelEngine

app = FastAPI()

# Initialize Model Engine once on startup
boss_model = BossModelEngine()

class DiagnosisResponse(BaseModel):
    label: str
    confidence: float
    action_plan: str
    audio_url: Optional[str] = None

@app.get("/")
def read_root():
    return {"message": "Boss Model Backend is Running"}

@app.post("/predict", response_model=DiagnosisResponse)
async def predict_disease(file: UploadFile = File(...)):
    # Read file bytes
    contents = await file.read()
    
    # Run Inference using the Boss Model Engine
    result = boss_model.predict(contents)
    
    # TODO: Call Bhashini handler here for translation/TTS based on result
    
    return {
        "label": result["label"],
        "confidence": result["confidence"],
        "action_plan": f"Treatment for {result['label']}: Apply proper fungicide...",
        "audio_url": "http://api.bhashini.gov.in/audio/mock_response.wav"
    }

# To run: uvicorn main:app --reload
