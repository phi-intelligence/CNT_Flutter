from fastapi import APIRouter
from socketio import AsyncServer
from typing import Any


class SocketIOHandler:
    """Handler for Socket.io real-time features"""
    
    def __init__(self, sio: AsyncServer):
        self.sio = sio
        self.setup_handlers()
    
    def setup_handlers(self):
        """Setup Socket.io event handlers"""
        
        @self.sio.on('connect')
        async def connect(sid: str, environ: dict, auth: dict):
            """Client connected"""
            print(f"Client connected: {sid}")
            await self.sio.emit('welcome', {'message': 'Connected to CNT Media Platform'}, room=sid)
        
        @self.sio.on('disconnect')
        async def disconnect(sid: str):
            """Client disconnected"""
            print(f"Client disconnected: {sid}")
        
        @self.sio.on('join_stream')
        async def join_stream(sid: str, data: dict):
            """Join a stream chat room"""
            stream_id = data.get('stream_id')
            if stream_id:
                room_name = f"stream_{stream_id}"
                await self.sio.enter_room(sid, room_name)
                await self.sio.emit('joined_stream', {'stream_id': stream_id}, room=sid)
        
        @self.sio.on('leave_stream')
        async def leave_stream(sid: str, data: dict):
            """Leave a stream chat room"""
            stream_id = data.get('stream_id')
            if stream_id:
                room_name = f"stream_{stream_id}"
                await self.sio.leave_room(sid, room_name)
        
        @self.sio.on('chat_message')
        async def chat_message(sid: str, data: dict):
            """Handle chat message"""
            stream_id = data.get('stream_id')
            message = data.get('message')
            username = data.get('username', 'Anonymous')
            
            if stream_id and message:
                room_name = f"stream_{stream_id}"
                # Broadcast message to all in room except sender
                await self.sio.emit(
                    'new_message',
                    {
                        'username': username,
                        'message': message,
                        'timestamp': data.get('timestamp')
                    },
                    room=room_name,
                    skip_sid=sid  # Don't send to sender
                )
        
        @self.sio.on('stream_update')
        async def stream_update(sid: str, data: dict):
            """Handle stream status update"""
            stream_id = data.get('stream_id')
            update_type = data.get('type')  # started, ended, viewer_count
            viewer_count = data.get('viewer_count', 0)
            
            if stream_id:
                room_name = f"stream_{stream_id}"
                await self.sio.emit(
                    'stream_status',
                    {
                        'stream_id': stream_id,
                        'type': update_type,
                        'viewer_count': viewer_count
                    },
                    room=room_name
                )

