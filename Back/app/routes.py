from flask import request, jsonify, Blueprint
from Back.app.db import *


api = Blueprint('api', __name__)  # 'api'는 블루프린트 이름

@api.route('/users', methods=['POST'])
def addUser():
    data = request.json  # 클라이언트에서 전달된 JSON 데이터
    new_user_ref = users_ref.push(data)  # Firebase에 데이터 추가
    return jsonify({"id": new_user_ref.key, "message": "User created successfully!"}), 201


@api.route('/users/<userId>', methods=['GET'])
def getUser(userId):
    try:
        # Realtime Database에서 userId에 해당하는 데이터 가져오기
        user_ref = db.reference(f'users/{userId}')
        user_data = user_ref.get()

        if user_data:
            # 문서 데이터를 JSON 형태로 반환
            return jsonify({"success": True, "data": user_data}), 200
        else:
            return jsonify({"success": False, "message": "User not found"}), 404

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

@api.route('/users/<userId>', methods=['DELETE'])
def deleteUser(userId):
    try:
        # Realtime Database에서 userId에 해당하는 데이터 가져오기
        user_ref = db.reference(f'users/{userId}')
        user_data = user_ref.get()

        if user_data:
            # userId 문서를 삭제
            user_ref.delete()
            return jsonify({"id": userId, "message": "User deleted successfully!"}), 200
        else:
            return jsonify({"success": False, "message": "User not found"}), 404

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@api.route('/friends/<userId>', methods=['POST'])
def addFriend(userId):
    try:
        # 클라이언트에서 전달받은 friendId 데이터
        data = request.json  # friendId
        friendId = data.get("friend_id")

        if not friendId:
            return jsonify({"success": False, "message": "friendId is required"}), 400

        # Firebase의 friendLists 컬렉션에 userId와 friendId를 포함한 데이터 추가
        friendLists_ref.push({
            "user_id": userId,
            "friend_id": friendId
        })

        return jsonify({
            "message": "Friend added successfully!"
        }), 201

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500



@api.route('/friends/<userId>', methods=['DELETE'])
def deleteFriend(userId):
    try:
        # 클라이언트에서 전달받은 friendId 데이터
        data = request.json  # friendId
        friendId = data.get("friend_id")

        # friendLists 경로 참조
        friendLists_ref = db.reference('friendLists')

        # userId와 friendId를 조건으로 데이터 검색
        query = friendLists_ref.order_by_child('user_id').equal_to(userId).get()

        # 검색 결과에서 friendId 매칭 확인
        for flistId, value in query.items():
            if value.get('friendId') == friendId:
                value.delete()
            return jsonify({"id": userId, "message": "friend ", friendId: "was deleted successfully!"}), 200

        return jsonify({
            "message": "Friend added successfully!"
        }), 201

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


#방생성
@api.route('/rooms/<userId>', methods=['POST'])
def createRoom(userId):
    try:
        data = request.json
        roomName = data.get("room_name")
        createdAt = data.get("created_at")

        newRoom = chatRooms_ref.push({
            "room_name" :  roomName,
            "created_at" : createdAt
        })

        #roommember에 등록
        roomMember_ref.push({
            "user_id": userId,
            "room_id": newRoom.get("room_id")
        })

        return jsonify({
            "message": "ChatRoom created successfully!"
        }), 201

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500

#초대코드 생성
@api.route('/rooms/<roomId>/invitation', methods=['POST'])
def createRoomCode():
    try:
        data = request.json
        created_by = data.get("created_by"),
        expires_at = data.get("expires_at")

        #invitationCode make
        invitationCode ="1234"
        return jsonify({
            "message" : f"your invitation code is {invitationCode} "
        }), 201

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


#초대코드로 방 입장
@api.route('/rooms/join', methods=['POST'])
def joinRoom(userId):
    try:
        data = request.json
        userId = data.get("user_id")
        invitationCode = data.get("invitation_code")

        #invitationCode 검색
        room_data = inviteCodes_ref.get(invitationCode)

        # 초대 코드가 존재하지 않는 경우
        if not room_data:
            return jsonify({"error": "Invalid invitation code"}), 404

        # roommember에 등록
        roomMember_ref.push({
            "user_id": userId,
            "room_id": room_data.get("room_id")
        })

        return jsonify({
            "message": "ChatRoom joined successfully!"
        }), 201

    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


#방 나가기
@api.route('/rooms/<roomId>/users/<userId>', methods=['DELETE'])
def leaveRoom(roomId, userId):
    try:
        # 방이 존재하지 않는 경우
        if roomId not in chatRooms_ref:
            return jsonify({"error": "Room not found"}), 404

        # 사용자가 방에 속하지 않은 경우
        if userId not in chatRooms_ref[roomId]["users"]:
            return jsonify({"error": f"User {userId} is not in room {roomId}"}), 404

        # 사용자를 방에서 제거
        chatRooms_ref[roomId]["users"].remove(userId)

        return jsonify({"message": f"User {userId} successfully left room {roomId}"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


