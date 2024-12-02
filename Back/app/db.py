import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

from dotenv import load_dotenv

load_dotenv()

#firebase 인증, 초기화
cred = credentials.Certificate(os.getenv("FIREBASE_KEY_PATH"))
firebase_admin.initialize_app(cred)

db = firestore.client()

# Firestore 컬렉션 참조
budget_ref = db.collection("Budget")
chatroom_ref = db.collection("ChatRoom")
message_ref = db.collection("Message")
roomMember_ref = db.collection("RoomMember")
schedule_ref = db.collection("Schedule")
user_ref = db.collection("User")

