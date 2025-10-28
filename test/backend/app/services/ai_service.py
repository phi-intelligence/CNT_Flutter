from openai import OpenAI
from deepgram import DeepgramClient, PrerecordedOptions
from app.config import settings


class AIService:
    """Service for AI voice assistant using OpenAI and Deepgram"""
    
    def __init__(self):
        # Only initialize clients if API keys are provided
        self.openai_client = None
        self.deepgram_client = None
        
        if settings.OPENAI_API_KEY:
            self.openai_client = OpenAI(api_key=settings.OPENAI_API_KEY)
        
        if settings.DEEPGRAM_API_KEY:
            self.deepgram_client = DeepgramClient(settings.DEEPGRAM_API_KEY)
    
    async def transcribe_audio(self, audio_data: bytes) -> str:
        """Transcribe audio to text using Deepgram"""
        if not self.deepgram_client:
            return "AI services not configured"
        
        try:
            payload = {"buffer": audio_data}
            options = PrerecordedOptions(
                model="nova-2",
                smart_format=True,
            )
            
            response = self.deepgram_client.listen.rest.v("1").transcribe_file(payload, options)
            transcript = response.results.channels[0].alternatives[0].transcript
            return transcript
        except Exception as e:
            print(f"Error transcribing audio: {e}")
            return ""
    
    async def generate_response(self, user_message: str, context: str = "") -> str:
        """Generate AI response using OpenAI GPT"""
        if not self.openai_client:
            return "AI services not configured. Please provide API keys."
        
        try:
            system_prompt = """You are an AI assistant for Christ New Tabernacle, a Christian media platform. 
            Help users with:
            - Bible verses and scripture
            - Prayer requests
            - Christian content recommendations
            - Faith-based questions
            - Daily devotionals
            
            Be warm, helpful, and grounded in Christian faith."""
            
            response = self.openai_client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": context + "\n\n" + user_message if context else user_message}
                ],
                temperature=0.7,
                max_tokens=300
            )
            
            return response.choices[0].message.content
        except Exception as e:
            print(f"Error generating response: {e}")
            return "I'm sorry, I'm having trouble processing your request right now."
    
    async def text_to_speech(self, text: str) -> bytes:
        """Convert text to speech using OpenAI TTS"""
        if not self.openai_client:
            return b""
        
        try:
            response = self.openai_client.audio.speech.create(
                model="tts-1",
                voice="alloy",
                input=text
            )
            
            # Return audio data
            return response.content
        except Exception as e:
            print(f"Error with text-to-speech: {e}")
            return b""

