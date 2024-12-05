from datetime import datetime

from flask import jsonify, Blueprint

from Back.app.db import *
from Back.app.ollama import *
import traceback  # 오류 추적용

api = Blueprint('api', __name__)  # 'api'는 블루프린트 이름


def requestAI(ai_payload, roomId):
    # AI 함수 호출
    ai_response_data = analyze_conversation(ai_payload)

    # AI 응답 데이터를 Firestore에 저장
    return ai_response_data

def upload_firestore(data, roomId):
    try:
        # Firestore의 Schedule 컬렉션 참조
        print("[INFO] Firestore 컬렉션 참조 시작")
        schedule_collection = db.collection("Message").document(roomId).collection("schedule")
        print(f"[DEBUG] Schedule 컬렉션: {schedule_collection.id}")


        # JSON 데이터 처리 - Schedule
        print("[INFO] Schedule 데이터 처리 시작")
        try:
            schedule_data = {
                "name": data.get("name", ""),
                "start": datetime.strptime(data["start"], "%Y-%m-%d-%H:%M") if data.get("start") else None,
                "end": datetime.strptime(data["end"], "%Y-%m-%d-%H:%M") if data.get("end") else None,
                "location": data.get("location", ""),
                "detail": data.get("detail", "")
            }
            print(f"[DEBUG] 파싱된 Schedule 데이터: {schedule_data}")
        except Exception as parse_error:
            print(f"[ERROR] Schedule 데이터 파싱 실패: {parse_error}")
            return jsonify({"status": "failure", "message": "Invalid schedule data format."}), 400

        # Firestore에 Schedule 데이터 삽입 (ID 자동 생성)
        try:
            print("[INFO] Schedule 데이터 Firestore 삽입 시작")
            doc_ref = schedule_collection.add(schedule_data)  # 스케줄 문서 생성
            schedule_doc_id = doc_ref[1].id  # 생성된 문서 ID 가져오기
            print(f"[DEBUG] Firestore에 Schedule 데이터 삽입 성공. 문서 ID: {schedule_doc_id}")
        except Exception as firestore_error:
            print(f"[ERROR] Firestore에 Schedule 데이터 삽입 실패: {firestore_error}")
            return jsonify({"status": "failure", "message": "Failed to add schedule data."}), 500

        # JSON 데이터 처리 - Budget
        print("[INFO] Budget 데이터 처리 시작")
        try:
            # Schedule 문서의 하위 컬렉션으로 Budget 추가
            budget_collection = schedule_collection.document(schedule_doc_id).collection("budget")
            for budget_item in data.get("budget", []):
                budget_data = {
                    "id":schedule_doc_id,
                    "name": budget_item.get("name", ""),
                    "category": budget_item.get("category", ""),
                    "amount": budget_item.get("amount", 0),
                }
                print(f"[DEBUG] Budget 데이터 추가: {budget_data}")
                budget_collection.add(budget_data)
            print("[INFO] Budget 데이터 Firestore 삽입 완료")
        except Exception as budget_error:
            print(f"[ERROR] Budget 데이터 Firestore 삽입 실패: {budget_error}")
            return jsonify({"status": "failure", "message": "Failed to add budget data."}), 500

        # 성공 응답 반환
        print("[INFO] 모든 데이터 처리 완료. 성공 응답 반환")
        return jsonify({"status": "success", "message": "Data uploaded successfully."}), 200

    except Exception as e:
        # 최종 에러 응답
        print(f"[ERROR] 예기치 못한 에러 발생: {e}")
        return jsonify({"status": "failure", "message": "Unexpected error occurred."}), 500


@api.route('/ai/<roomID>', methods=['POST'])
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

            # User 컬렉션에서 user_id와 매칭되는 name 가져오기
        user_names = {}
        for message in message_list:
            user_id = message["user_id"]
            if user_id not in user_names:  # 이미 조회된 user_id는 다시 검색하지 않음
                user_doc = db.collection("User").document(user_id).get()
                if user_doc.exists:
                    user_names[user_id] = user_doc.to_dict().get("name", "Unknown")  # name 필드 가져오기
                else:
                    user_names[user_id] = "Unknown"  # 문서가 없으면 Unknown

        # 파싱된 메시지 (JSON 형태로 유지)
        parsed_messages = [
            {
                "user_id": user_names.get(message["user_id"], "Unknown"),
                "content": message["content"]
            }
            for message in message_list
        ]

        upload_firestore(requestAI(parsed_messages, roomID), roomID)


        # 새로운 메시지 중 가장 최근의 timestamp 가져오기
        new_last_timestamp = message_list[-1]["timestamp"]

        # last_timestamp 필드 확인 및 삽입 또는 업데이트
        if not room_doc.exists:
            # last_timestamp 필드가 없을 경우 삽입
            message_ref.set({"last_timestamp": new_last_timestamp}, merge=True)  # merge=True로 기존 데이터 유지

        #else:
            # last_timestamp 필드가 있을 경우 업데이트
            #message_ref.update({"last_timestamp": new_last_timestamp})

        return jsonify({"status": "success", "message": "Schedule and Budget processed successfully"}), 200


    except Exception as e:
        # 예외 처리 및 실패 응답
        return jsonify({"status": "failure", "message": "An error occurred", "error": str(e), "trace": traceback.format_exc()}), 500

