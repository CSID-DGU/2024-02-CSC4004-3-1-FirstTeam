// chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> chatRoom;

  const ChatRoomScreen({required this.chatRoom, super.key});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 메시지 전송 함수
  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user != null && _messageController.text.isNotEmpty) {
      await _firestore
          .collection('Message')
          .doc(widget.chatRoom['id'])
          .collection('messages')
          .add({
        'user_id': user.uid,
        'content': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  // 유저 이름 가져오기 함수
  Future<String> _getUserName(String userId) async {
    final userDoc = await _firestore.collection('User').doc(userId).get();
    return userDoc.data()?['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 4.0, // AppBar에 옅은 그림자 추가
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 채팅방 이름의 첫 글자를 아이콘으로 표시
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                widget.chatRoom['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            // 채팅방 이름
            Text(
              widget.chatRoom['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_calendar),
              onPressed: () {
                // 일정 관리 화면으로 이동
              }),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 사이드 바 추가 동작
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFCFCF7), // 채팅방 배경색 변경
        child: Column(
          children: [
            // 메시지 리스트
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Message')
                    .doc(widget.chatRoom['id'])
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final messageData =
                          message.data() as Map<String, dynamic>;
                      final isMe =
                          messageData['user_id'] == _auth.currentUser?.uid;
                      return FutureBuilder<String>(
                        future: _getUserName(messageData['user_id']),
                        builder: (context, userNameSnapshot) {
                          if (!userNameSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          return ListTile(
                            title: Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        userNameSnapshot.data!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    Text(
                                      messageData['content'],
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // 메시지 입력창
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.6,
                    blurRadius: 3,
                    offset: const Offset(0, -2), // 위쪽 방향으로 그림자
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // + 버튼 클릭 시 동작 추가
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF0F0F0), // 옅은 회색 배경색
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
