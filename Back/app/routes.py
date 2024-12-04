from types import NoneType

from flask import request, jsonify, Blueprint
from Back.app.db import *
from Back.app.ollama import *
import requests  # AI API 호출을 위한 라이브러리 (예시)
import traceback  # 오류 추적용
from datetime import datetime

api = Blueprint('api', __name__)  # 'api'는 블루프린트 이름


def requestAI(ai_payload, roomId):
    # AI API 호출
    ai_api_url = "https://example-ai-api.com/query"  # AI API URL (실제 엔드포인트로 변경)
    ai_api_headers = {"Content-Type": "application/json"}
    ai_response = requests.post(ai_api_url, json=ai_payload, headers=ai_api_headers)

    if ai_response.status_code != 200:
        return jsonify({"status": "failure", "message": "AI API call failed", "details": ai_response.text}), 500

    ai_response_data = ai_response.json()

    # AI 응답 데이터를 Firestore에 저장
    upload_firestore(ai_response_data, roomId)

    # 성공 여부 응답
    return jsonify({"status": "success", "message": "AI response processed and stored successfully"}), 200

def upload_firestore(data, roomId):
    try:
        # Firestore의 Schedule 및 Budget 컬렉션 참조
        schedule_collection = db.collection("Message").document(roomId).collection("schedule")
        budget_collection = db.collection("Message").document(roomId).collection("budget")

        # JSON 데이터 처리 - Schedule
        schedule_data = {
            "name": data.get("name", ""),
            "start": data.get("start"),
            "end": data.get("end"),
            "location": data.get("location", ""),
            "detail": data.get("detail", "")
        }

        # ID가 있는 경우 수정, 없으면 새 문서 생성
        if "id" in data and data["id"]:  # AI 응답에 'id' 필드가 있는 경우
            existing_schedule_doc_ref = schedule_collection.document(data["id"])
            if existing_schedule_doc_ref.get().exists:  # 문서가 존재하면 업데이트
                existing_schedule_doc_ref.update(schedule_data)
            else:  # 문서가 존재하지 않으면 새로 생성
                new_schedule_doc_ref = schedule_collection.document(data["id"])
                schedule_data["id"] = new_schedule_doc_ref.id
                new_schedule_doc_ref.set(schedule_data)
        else:  # 'id'가 없으면 새 문서 생성
            new_schedule_doc_ref = schedule_collection.document()
            schedule_data["id"] = new_schedule_doc_ref.id
            new_schedule_doc_ref.set(schedule_data)

        # JSON 데이터 처리 - Budget
        for budget_item in data.get("budget", []):
            budget_collection.add({
                "name": budget_item.get("name", ""),
                "category": budget_item.get("category", ""),
                "amount": budget_item.get("amount", 0),
            })

        # 성공 응답
        return jsonify({"status": "success", "message": "Schedule and Budget processed successfully"}), 200

    except Exception as e:
        # 에러 응답
        return jsonify({"status": "failure", "message": str(e)}), 500


@api.route('/ai/<roomID>', methods=['GET'])
def getAI(roomID):
    try:
        # Firestore에서 room_id 문서와 messages 하위 컬렉션 접근
        message_ref = db.collection("Message").document(roomID)

        room_doc = message_ref.get()


        # messages 하위 컬렉션에서 timestamp 기준으로 새로운 메시지만 가져오기
        message_subcollection_ref = message_ref.collection("messages")
        messages_query = message_subcollection_ref.order_by("timestamp")

        if room_doc.exists:
            # last_timestamp 가져오기
            last_timestamp = room_doc.to_dict().get("last_timestamp")

            if last_timestamp:
                messages_query = messages_query.where("timestamp", ">", last_timestamp)


        # Firestore에서 쿼리 실행
        messages = messages_query.get()

        # 메시지 리스트로 변환
        message_list = [msg.to_dict() for msg in messages]

        # 새로운 메시지 존재 여부 확인
        if not message_list:
            return {"status": "success", "message": "No new messages since last_timestamp."}

        # 파싱된 메시지 (JSON 형태로 유지)
        parsed_messages = [
            {
                "user_id": message["user_id"],
                "content": message["content"]
            }
            for message in message_list
        ]
        # 새로운 메시지 중 가장 최근의 timestamp 가져오기
        new_last_timestamp = message_list[-1]["timestamp"]

        # last_timestamp 필드 확인 및 삽입 또는 업데이트
        if not room_doc.exists:
            # last_timestamp 필드가 없을 경우 삽입
            message_ref.set({"last_timestamp": new_last_timestamp}, merge=True)  # merge=True로 기존 데이터 유지
        else:
            # last_timestamp 필드가 있을 경우 업데이트
            message_ref.update({"last_timestamp": new_last_timestamp})
        print(f"{parsed_messages}")

      #  return jsonify(parsed_messages)

        requestAI(parsed_messages, roomID)

    except Exception as e:
        # 예외 처리 및 실패 응답
        return jsonify({"status": "failure", "message": "An error occurred", "error": str(e), "trace": traceback.format_exc()}), 500

