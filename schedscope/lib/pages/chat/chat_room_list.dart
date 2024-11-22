// chat_room_list.dart
import 'package:flutter/material.dart';

class ChatRoomList extends StatelessWidget {
  final List<Map<String, dynamic>> chatRooms = [
    {
      'name': 'General Chat',
      'lastMessage': 'Hello everyone!',
      'participants': 10
    },
    {
      'name': 'Flutter Devs',
      'lastMessage': 'Flutter 2.0 is awesome!',
      'participants': 25
    },
    {
      'name': 'Random',
      'lastMessage': 'Did you see the game last night?',
      'participants': 5
    },
  ];

  ChatRoomList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = chatRooms[index];
          print(
              'Chat Room: ${chatRoom['name']}, Participants: ${chatRoom['participants']}'); // 디버깅 출력
          return ListTile(
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
            subtitle: Text(
              chatRoom['lastMessage']!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Text(
              '${chatRoom['participants'] ?? 0}명', // 참여자 수 표시
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            onTap: () {
              // 채팅방 항목을 클릭했을 때 동작
              print('Tapped on ${chatRoom['name']}');
            },
          );
        },
      ),
    );
  }
}
