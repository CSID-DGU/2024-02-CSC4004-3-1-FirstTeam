// chat_room_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'chat_room_list.dart';
import 'package:schedscope/pages/chat/schedule/schedule.dart';

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
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

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

  // // 사이드바 화면
  // void _showSideBar(BuildContext context) {
  //   Scaffold.of(context).openEndDrawer();
  // }

  // 초대 코드 다이얼로그 표시 함수
  void _showInviteCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('초대 코드')),
          content: SingleChildScrollView(
            child: Center(
              child: Text(widget.chatRoom['id']),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('복사'),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.chatRoom['id']));
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    Navigator.of(context).pop(); // 사이드바 닫기
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('초대 코드가 복사되었습니다.')),
                    );
                  },
                ),
                const SizedBox(width: 8), // 버튼 사이의 간격
                TextButton(
                  child: const Text('닫기'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 방 나가기 함수
  Future<void> _leaveChatRoom() async {
    final String? userId = _user?.uid;
    final String roomId = widget.chatRoom['id'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 가져올 수 없습니다. 다시 로그인 해주세요.')),
      );
      return;
    }

    final DocumentReference roomRef =
        _firestore.collection('ChatRoom').doc(roomId);
    final DocumentReference userRef =
        _firestore.collection('RoomMember').doc(userId);
    final CollectionReference messageRef =
        _firestore.collection('Message').doc(roomId).collection('messages');

    // 확인 다이얼로그 표시
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('방 나가기')),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10), // 타이틀과 콘텐츠 사이의 간격
              Text('정말로 해당 채팅방을 나가시겠습니까?\n'),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 10.0), // 위아래 간격 조정
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // 취소
                    },
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // 확인
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return; // 사용자가 확인을 누르지 않으면 함수 종료
    }

    await _firestore.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(roomRef);
      final userSnapshot = await transaction.get(userRef);
      // final msgSnapshot = await transaction.get(msgRef);

      if (roomSnapshot.exists && userSnapshot.exists) {
        final int participants = roomSnapshot['participants'] - 1;

        if (participants == 0) {
          // 방과 메시지 삭제
          final batch = _firestore.batch();
          batch.delete(roomRef);

          final messagesSnapshot = await messageRef.get();
          for (final doc in messagesSnapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();
        } else {
          transaction.update(roomRef, {
            'participants': participants,
            'room_member_id': FieldValue.arrayRemove([userId]),
          });
        }

        transaction.update(userRef, {
          'room_id_list': FieldValue.arrayRemove([roomId]),
        });
      }
    });

    Navigator.of(context).pop(); // 사이드바 닫기
    Navigator.of(context).pop(); // 이전 화면으로 돌아가기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('방 나가기가 완료되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 4.0, // AppBar에 옅은 그림자 추가
        shadowColor: Colors.black.withOpacity(0.5),
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
      ),

      /* 사이드바 */
      endDrawer: Drawer(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 초대 버튼
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      _showInviteCodeDialog(context); // 초대 코드 다이얼로그 표시
                    },
                  ),
                  // 알림 토글 버튼
                  IconButton(
                    icon: Icon(_notificationsEnabled
                        ? Icons.notifications
                        : Icons.notifications_off),
                    onPressed: _toggleNotifications,
                  ),
                  // 방 나가기 버튼
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: _leaveChatRoom,
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                height: 1.0,
                color: Colors.black,
              ),
              const SizedBox(height: 16.0),
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

                    if (!snapshot.data!.exists) {
                      // 데이터가 없거나 문서가 존재하지 않는 경우
                      return const Center(child: Text('채팅방이 존재하지 않습니다.'));
                    }

                    final roomData =
                        snapshot.data!.data() as Map<String, dynamic>?;

                    if (roomData == null) {
                      return const Center(child: Text('채팅방 데이터를 불러올 수 없습니다.'));
                    }

                    final participants =
                        List<String>.from(roomData['room_member_id'] ?? []);
                    final participantCount = participants.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.group, size: 20),
                            const SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                            const Text(
                              '참여자 ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '($participantCount명)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
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
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Center(
                          child: SizedBox(
                            width: double.infinity, // 버튼이 좌우 여백을 꽉 채우도록 설정
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // 일정 관리 화면으로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchedulePage(
                                        roomId: widget.chatRoom['id']),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_calendar), // 아이콘 추가
                              label: const Text(
                                '일정 관리',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600, // 폰트를 bold로 설정
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
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
                      final timestamp = messageData['timestamp']?.toDate();
                      final koreanTime =
                          timestamp?.add(const Duration(hours: 9));
                      final formattedTime = koreanTime != null
                          ? "${koreanTime.month.toString().padLeft(2, '0')}/${koreanTime.day.toString().padLeft(2, '0')} ${koreanTime.hour.toString().padLeft(2, '0')}:${koreanTime.minute.toString().padLeft(2, '0')}"
                          : "Unknown time";

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
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.77,
                                ),
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
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                        fontSize: 10,
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
