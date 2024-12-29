from telethon.sessions import StringSession
from telethon import TelegramClient

api_id = 21094186
api_hash = 'd0101c870fc0df554091614c384bc055'

with TelegramClient(StringSession(), api_id, api_hash) as client:
    print(client.session.save())