import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
from dotenv import load_dotenv

load_dotenv()

#firebase 인증, 초기화
cred = credentials.Certificate(os.getenv("FIREBASE_KEY_PATH"))
firebase_admin.initialize_app(cred, {'databaseURL' : os.getenv("FIREBASE_URL")})

users_ref = db.reference("users")
schedules_ref = db.reference("schedules")
photos_ref = db.reference("photos")
messages_ref = db.reference("messages")
inviteCodes_ref = db.reference("inviteCodes")
friendLists_ref = db.reference("friendLists")
chatRooms_ref = db.reference("chatRooms")
roomMember_ref = db.reference("RoomMembers")
budgets_ref = db.reference("budgets")

