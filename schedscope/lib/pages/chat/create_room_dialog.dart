// create_room_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showCreateRoomDialog(BuildContext context) async {
  final TextEditingController roomNameController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // 다이얼로그 바깥을 터치해도 닫히지 않음
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('새 채팅방 만들기')),
        content: SingleChildScrollView(
          child: Center(
            child: ListBody(
              children: <Widget>[
                const Center(child: Text('채팅방의 이름을 입력하세요')),
                const SizedBox(height: 8), // 위젯 사이의 간격
                TextField(
                  controller: roomNameController,
                  decoration: const InputDecoration(
                    hintText: '채팅방 이름',
                    hintStyle:
                        TextStyle(color: Colors.grey), // hintText 색상 연하게 설정
                  ),
                  textAlign: TextAlign.center, // 텍스트 필드 내용 가운데 정렬
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 8), // 버튼 사이의 간격
              TextButton(
                child: const Text('생성'),
                onPressed: () async {
                  final String roomName = roomNameController.text;
                  if (roomName.isNotEmpty) {
                    await _createChatRoom(roomName);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> _createChatRoom(String roomName) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = auth.currentUser;

  if (user != null) {
    final newRoomRef = firestore.collection('ChatRoom').doc();
    await newRoomRef.set({
      'room_name': roomName,
      'participants': 1,
      'created_at': FieldValue.serverTimestamp(),
      'room_member_id': [user.uid], // room_member_id 배열에 자신의 user_id 추가
    });

    final roomMemberRef = firestore.collection('RoomMember').doc(user.uid);
    await roomMemberRef.set({
      'room_id_list': FieldValue.arrayUnion([newRoomRef.id]),
    }, SetOptions(merge: true));
  }
}
