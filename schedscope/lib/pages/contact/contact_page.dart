// contact_page.dart
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final List<Map<String, String>> contacts = [
    {'name': 'NAYEON', 'number': '010-4588-3051'},
  ];

  void _addNewContact() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String friendCode = '';
        return AlertDialog(
          title: const Center(child: Text('친구 코드 입력')),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '친구 코드를 입력하세요',
                    hintStyle:
                        TextStyle(color: Colors.grey), // hintText 색상 연하게 설정
                  ),
                  textAlign: TextAlign.center, // 텍스트 필드 내용 가운데 정렬
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
                  onPressed: () {
                    if (friendCode.isNotEmpty) {
                      setState(() {
                        // 친구 코드를 통해 친구를 추가하는 로직을 여기에 추가
                        // 예시로 임시 데이터를 추가합니다.
                        contacts.add({'name': '친구 이름', 'number': friendCode});
                      });
                      Navigator.of(context).pop();
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
        //elevation: 0.0,

        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.black),
            onPressed: _addNewContact,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  contact['name']![0], // 이름 첫 글자 표시
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                contact['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // subtitle: Text(
              //   contact['number']!,
              //   style: const TextStyle(fontSize: 14, color: Colors.grey),
              // ),
              onTap: () {
                // 연락처 클릭 시 동작
              },
            );
          },
        ),
      ),
    );
  }
}
