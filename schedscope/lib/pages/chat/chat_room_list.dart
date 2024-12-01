// chat_room_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_room.dart'; // ChatRoomScreen 임포트
import 'create_room_dialog.dart'; // 방 생성 다이얼로그 임포트
import 'package:schedscope/main.dart';

class ChatRoomList extends StatefulWidget {
  const ChatRoomList({super.key});

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> with RouteAware {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> chatRooms = [];
  User? _user;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchChatRooms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 현재 라우트로 돌아올 때 호출
    _fetchChatRooms();
  }

  void _toggleButtons() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  void _fetchUser() {
    _user = _auth.currentUser;
  }

  // 채팅방 목록 조회
  Future<void> _fetchChatRooms() async {
    final user = _user;
    if (user != null) {
      final roomMemberSnapshot =
          await _firestore.collection('RoomMember').doc(user.uid).get();

      if (roomMemberSnapshot.exists) {
        final roomIds =
            List<String>.from(roomMemberSnapshot.data()?['room_id_list'] ?? []);
        List<Map<String, dynamic>> newChatRooms = [];
        for (final roomId in roomIds) {
          final chatRoomSnapshot =
              await _firestore.collection('ChatRoom').doc(roomId).get();

          if (chatRoomSnapshot.exists) {
            final chatRoomData = chatRoomSnapshot.data();
            if (chatRoomData != null) {
              newChatRooms.add({
                'id': roomId,
                'name': chatRoomData['room_name'],
                'participants': chatRoomData['participants'],
                'created_at':
                    (chatRoomData['created_at'] as Timestamp).toDate(),
              });
            }
          }
        }
        setState(() {
          chatRooms = newChatRooms;
        });
      }
    }
  }

  // 방 만들기
  Future<void> _joinChatRoom(BuildContext context) async {
    final TextEditingController roomIdController = TextEditingController();
    final String? userId = _user?.uid; // 자신의 user_id를 여기에 설정

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 가져올 수 없습니다. 다시 로그인 해주세요.')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('새 채팅 참여하기')),
          content: TextField(
            controller: roomIdController,
            decoration: const InputDecoration(
              hintText: 'Room ID를 입력하세요',
              hintStyle: TextStyle(color: Colors.grey), // hintText 색상 연하게 설정
            ),
            textAlign: TextAlign.center, // 텍스트 필드 내용 가운데 정렬
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8), // 버튼 사이의 간격
                TextButton(
                  onPressed: () async {
                    final String roomId = roomIdController.text;
                    if (roomId.isNotEmpty) {
                      final DocumentReference roomRef = FirebaseFirestore
                          .instance
                          .collection('ChatRoom')
                          .doc(roomId);
                      final DocumentReference userRef = FirebaseFirestore
                          .instance
                          .collection('RoomMember')
                          .doc(userId);

                      final DocumentSnapshot roomSnapshot = await roomRef.get();
                      final DocumentSnapshot userSnapshot = await userRef.get();

                      if (roomSnapshot.exists) {
                        final userData = userSnapshot.data()
                            as Map<String, dynamic>?; // 데이터 캐스팅
                        final userRoomIds =
                            List<String>.from(userData?['room_id_list'] ?? []);
                        if (userRoomIds.contains(roomId)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이미 참여한 채팅방입니다.')),
                          );
                        } else {
                          await roomRef.update({
                            'participants': FieldValue.increment(1),
                            'room_member_id': FieldValue.arrayUnion([userId]),
                          });

                          await userRef.update({
                            'room_id_list': FieldValue.arrayUnion([roomId]),
                          });

                          Navigator.of(context).pop();
                          _fetchChatRooms(); // 채팅방 목록 다시 조회
                        }
                      } else {
                        // 방이 존재하지 않는 경우
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('해당 Room ID가 존재하지 않습니다.')),
                        );
                      }
                    }
                  },
                  child: const Text('참여하기'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        // 그림자
        //elevation: 0.0,
        // 밑줄
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(4.0),
        //   child: Container(
        //     margin: const EdgeInsets.symmetric(horizontal: 16.0),
        //     height: 2.0,
        //     decoration: BoxDecoration(
        //       color: Colors.black12,
        //       borderRadius: BorderRadius.circular(2.0),
        //     ),
        //   ),
        // ),
      ),
      body: Container(
        color: const Color(0xffffffff), // 배경색 변경
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
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                    ),
                    onPressed: () async {
                      await showCreateRoomDialog(context); // 방 만들기 다이얼로그 호출
                      _fetchChatRooms(); // 채팅방 목록 다시 조회
                    },
                    child: const Text('채팅방 생성하기'),
                  ),
                  const SizedBox(height: 15), // 버튼 사이의 간격
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                    ),
                    onPressed: () {
                      _joinChatRoom(context);
                    },
                    child: const Text('새 채팅 참여하기'),
                  ),
                  const SizedBox(height: 10), // 버튼 사이의 간격
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleButtons,
              child: Icon(_showButtons ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
