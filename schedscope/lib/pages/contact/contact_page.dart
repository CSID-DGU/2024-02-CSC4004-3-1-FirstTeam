import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final user = _auth.currentUser;
    if (user != null) {
      final friendListSnapshot =
          await _firestore.collection('FriendList').doc(user.uid).get();

      if (friendListSnapshot.exists) {
        final friendIds = List<String>.from(
            friendListSnapshot.data()?['friend_id_list'] ?? []);
        List<Map<String, dynamic>> newContacts = [];
        for (final friendId in friendIds) {
          final userSnapshot =
              await _firestore.collection('User').doc(friendId).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data();
            if (userData != null) {
              newContacts.add({
                'id': friendId,
                'name': userData['name'],
                'profile_image': userData['profile_image'],
                'email': userData['email'], // 이메일 필드 추가
              });
            }
          }
        }
        setState(() {
          contacts = newContacts;
        });
      }
    }
  }

  void _addNewContact() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String friendCode = '';
        return AlertDialog(
          title: const Center(child: Text('친구 코드 입력')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: '친구 코드를 입력하세요',
                    hintStyle:
                        TextStyle(color: Colors.grey), // hintText 색상 연하게 설정
                  ),
                  textAlign: TextAlign.center, // 텍스트 필드 내용 가운데 정렬
                  onChanged: (value) => friendCode = value,
                ),
              ],
            ),
          ),
          actions: [
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
                    final user = _auth.currentUser;
                    if (user != null && friendCode.isNotEmpty) {
                      final userRef =
                          _firestore.collection('User').doc(friendCode);
                      final userSnapshot = await userRef.get();

                      if (userSnapshot.exists) {
                        final friendListRef =
                            _firestore.collection('FriendList').doc(user.uid);
                        final friendListSnapshot = await friendListRef.get();

                        if (friendListSnapshot.exists) {
                          final friendIds = List<String>.from(
                              friendListSnapshot.data()?['friend_id_list'] ??
                                  []);
                          if (friendIds.contains(friendCode)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('이미 등록된 친구입니다.')),
                            );
                          } else {
                            await friendListRef.update({
                              'friend_id_list':
                                  FieldValue.arrayUnion([friendCode]),
                            });
                            _fetchContacts();
                            Navigator.of(context).pop();
                          }
                        } else {
                          await friendListRef.set({
                            'friend_id_list': [friendCode],
                          });
                          _fetchContacts();
                          Navigator.of(context).pop();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('해당 친구 코드를 가진 사용자가 없습니다.')),
                        );
                      }
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showContactProfile(Map<String, dynamic> contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('프로필 정보')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(contact['profile_image'] ?? ''),
                ),
                const SizedBox(height: 16),
                Text(
                  contact['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contact['email'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('닫기'),
              ),
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
          '연락처',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black),
            onPressed: _addNewContact,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFFFF), // 배경색 변경
        padding: const EdgeInsets.all(10),
        child: contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '아직 등록된 친구가 없습니다.\n새로운 친구를 추가해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5), // 위아래 간격 추가
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15), // 패딩 추가
                      tileColor: Colors.white, // 타일 배경색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                      ),
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(contact['profile_image'] ?? ''),
                      ),
                      title: Text(
                        contact['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        _showContactProfile(contact);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
