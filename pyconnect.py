from flask import Flask
from flask_socketio import SocketIO
from telethon import TelegramClient, events
import asyncio
from threading import Thread
from flask_cors import CORS  

api_id = 21094186
api_hash = 'd0101c870fc0df554091614c384bc055'

channel_ids = [
    -1001606035281,
    -1001697250541,
    -1001536630827,
    -1001855211672,
    -1001745595323,
    -1001641260594,
    -1001662388432,
    -1002397372319,
    -1001635151914
]

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

client = TelegramClient('session_name', api_id, api_hash)

@client.on(events.NewMessage)
async def handler(event):
    if event.chat_id in channel_ids:
        msg = {
            'channel_id': event.chat_id,
            'channel_name': event.chat.title if event.chat else "Unknown",
            'message_id': event.message.id,
            'message_text': event.message.text
        }
        print(f"New message: {msg}")
        socketio.emit('new_message', msg)  

@app.route('/')
def index():
    return "Server is running!"

async def start_client():
    await client.start()
    await client.run_until_disconnected()

def run_flask():
    socketio.run(app, host='0.0.0.0', port=5000)

if __name__ == '__main__':
    thread = Thread(target=run_flask)
    thread.start()

    loop = asyncio.get_event_loop()
    loop.run_until_complete(start_client())