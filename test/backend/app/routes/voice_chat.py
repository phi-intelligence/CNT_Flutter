from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.services.ai_service import AIService
import asyncio
import json

router = APIRouter()
ai_service = AIService()


@router.websocket("/ws/voice-chat")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for AI voice chat"""
    await websocket.accept()
    
    try:
        while True:
            # Receive audio data
            data = await websocket.receive_bytes()
            
            # Transcribe audio to text
            transcript = await ai_service.transcribe_audio(data)
            
            if transcript:
                # Send transcript back to client
                await websocket.send_text(json.dumps({
                    "type": "transcript",
                    "text": transcript
                }))
                
                # Generate AI response
                response_text = await ai_service.generate_response(transcript)
                
                # Send response text
                await websocket.send_text(json.dumps({
                    "type": "response",
                    "text": response_text
                }))
                
                # Convert response to speech
                audio_data = await ai_service.text_to_speech(response_text)
                
                # Send audio response
                await websocket.send_bytes(audio_data)
            
    except WebSocketDisconnect:
        print("Client disconnected from voice chat")

