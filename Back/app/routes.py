from flask import request, jsonify, Blueprint
from Back.app.db import *

api = Blueprint('api', __name__)  # 'api'는 블루프린트 이름

@api.route('/users', methods=['POST'])
def addUser():
    data = request.json  # 클라이언트에서 전달된 JSON 데이터
    new_user_ref = users_ref.push(data)  # Firebase에 데이터 추가
    return jsonify({"id": new_user_ref.key, "message": "User created successfully!"}), 201
