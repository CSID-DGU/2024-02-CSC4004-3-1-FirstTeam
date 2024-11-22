// chat_room_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room.dart'; // ChatRoomScreen 임포트

class ChatRoomList extends StatefulWidget {
  const ChatRoomList({super.key});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> chatRooms = [];

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final user = _auth.currentUser;
    if (user != null) {
      final roomMemberSnapshot =
          await _firestore.collection('RoomMember').doc(user.uid).get();

      if (roomMemberSnapshot.exists) {
        final roomIds =
            List<String>.from(roomMemberSnapshot.data()?['room_id_list'] ?? []);
        for (final roomId in roomIds) {
          final chatRoomSnapshot =
              await _firestore.collection('ChatRoom').doc(roomId).get();

          if (chatRoomSnapshot.exists) {
            final chatRoomData = chatRoomSnapshot.data();
            if (chatRoomData != null) {
              setState(() {
                chatRooms.add({
                  'id': roomId,
                  'name': chatRoomData['room_name'],
                  'participants': chatRoomData['participants'],
                  'created_at':
                      (chatRoomData['created_at'] as Timestamp).toDate(),
                });
              });
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x00ffffff), // 배경색 변경
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5), // 위아래 간격 추가
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 15), // 패딩 추가
              tileColor: Colors.white, // 타일 배경색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  chatRoom['name']![0], // 채팅방 이름 첫 글자 표시
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                chatRoom['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.group, color: Colors.grey), // 아이콘 추가
                  const SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격
                  Text(
                    '${chatRoom['participants']}명', // 참여자 수를 오른쪽에 표시
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                // 채팅방 항목을 클릭했을 때 동작
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
