// chat_room_screen.dart
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  final Map<String, dynamic> chatRoom;

  const ChatRoomScreen({required this.chatRoom, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatRoom['name']),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Participants: ${chatRoom['participants']}'),
                ),
                // 여기에 더 많은 메시지를 추가할 수 있습니다.
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // 메시지 전송 기능 구현
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
