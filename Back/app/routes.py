from flask import request, jsonify, Blueprint
from Back.app.db import *
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
        # Firestore의 Schedule 및 Buget 컬렉션 참조
        schedule_collection = db.collection("Message").document(roomId).collection("schedule")
        buget_collection = db.collection("Message").document(roomId).collection("buget")

        # JSON 데이터 처리
        for item in data.get("schedules", []):  # schedules 키 안의 데이터를 반복
            schedule_id = item.get("id")  # AI 모듈에서 받은 데이터의 'id'

            # ID가 없으면 새로운 스케줄 생성
            if not schedule_id:
                new_doc_ref = schedule_collection.document()  # 새 문서 ID 생성
                new_doc_ref.set({
                    "detail": item.get("detail", ""),
                    "end": item.get("end"),
                    "id": new_doc_ref.id,  # Firestore에서 자동 생성한 ID
                    "location": item.get("location", ""),
                    "name": item.get("name", ""),
                    "start": item.get("start"),
                })
            else:
                # ID가 존재하면 해당 스케줄 업데이트
                existing_doc_ref = schedule_collection.document(schedule_id)
                if existing_doc_ref.get().exists:
                    # 문서가 이미 존재하면 업데이트
                    existing_doc_ref.update({
                        "detail": item.get("detail", ""),
                        "end": item.get("end"),
                        "location": item.get("location", ""),
                        "name": item.get("name", ""),
                        "start": item.get("start"),
                    })
                else:
                    # 문서가 없으면 새로 생성
                    existing_doc_ref.set({
                        "detail": item.get("detail", ""),
                        "end": item.get("end"),
                        "id": schedule_id,
                        "location": item.get("location", ""),
                        "name": item.get("name", ""),
                        "start": item.get("start"),
                    })

        # Buget 데이터는 무조건 삽입
        for item in data.get("bugets", []):  # bugets 키 안의 데이터를 반복
            buget_collection.add({
                "amount": item.get("amount", 0),
                "category": item.get("category", ""),
                "description": item.get("description", ""),
                "timestamp": item.get("timestamp")
            })

        # 성공 응답
        return jsonify({"status": "success", "message": "Schedules and Bugets processed successfully"}), 200

    except Exception as e:
        # 에러 응답
        return jsonify({"status": "failure", "message": str(e)}), 500

@api.route('/ai/<roomID>', methods=['GET'])
def getAI(roomID):
    try:
        # Firestore에서 room_id 문서와 messages 하위 컬렉션 접근
        message_ref = db.collection("Message").document(roomID)
        room_doc = message_ref.get()

        # room_id 문서가 존재하는지 확인
        if not room_doc.exists:
            return {"status": "failure", "message": f"Room {roomID} not found."}

        # last_timestamp 가져오기
        last_timestamp = room_doc.to_dict().get("last_timestamp")

        # messages 하위 컬렉션에서 timestamp 기준으로 새로운 메시지만 가져오기
        message_subcollection_ref = message_ref.collection("messages")
        messages_query = message_subcollection_ref.order_by("timestamp")

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
        print(new_last_timestamp)
        # room_id 문서에 last_timestamp 업데이트
        message_ref.update({"last_timestamp": new_last_timestamp})

        print(f"{parsed_messages}")

        requestAI(parsed_messages, roomID)



    except Exception as e:
        # 예외 처리 및 실패 응답
        return jsonify({"status": "failure", "message": "An error occurred", "error": str(e), "trace": traceback.format_exc()}), 500

