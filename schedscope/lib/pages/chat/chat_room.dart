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
  bool _notificationsEnabled = true;

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
  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    final userDoc = await _firestore.collection('User').doc(userId).get();
    return userDoc.data() ?? {};
  }

  // 알림 토글 함수
  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
  }

  // 사이드바 화면
  void _showSideBar(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
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

        // 액션 아이콘
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit_calendar),
        //     onPressed: () {
        //       // 일정 관리 화면으로 이동
        //     },
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {
        //       _showSideBar(context); // 사이드바 표시
        //     },
        //   ),
        // ],
      ),
      endDrawer: Drawer(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      // 다른 사용자 초대하기 동작
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      // 방 나가기 동작
                    },
                  ),
                  IconButton(
                    icon: Icon(_notificationsEnabled
                        ? Icons.notifications
                        : Icons.notifications_off),
                    onPressed: _toggleNotifications,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                widget.chatRoom['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '참여자 목록',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('ChatRoom')
                      .doc(widget.chatRoom['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final roomData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final participants =
                        List<String>.from(roomData['room_member_id'] ?? []);
                    return ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final participantId = participants[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getUserInfo(participantId),
                          builder: (context, userInfoSnapshot) {
                            if (!userInfoSnapshot.hasData) {
                              return const ListTile(
                                title: Text('Loading...'),
                              );
                            }
                            final userInfo = userInfoSnapshot.data!;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    userInfo['profile_image'] ?? ''),
                              ),
                              title: Text(userInfo['name'] ?? 'Unknown'),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getUserInfo(messageData['user_id']),
                        builder: (context, userInfoSnapshot) {
                          if (!userInfoSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final userInfo = userInfoSnapshot.data!;
                          return ListTile(
                            leading: isMe
                                ? null
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        userInfo['profile_image'] ?? ''),
                                  ),
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
                                        userInfo['name'] ?? 'Unknown',
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
