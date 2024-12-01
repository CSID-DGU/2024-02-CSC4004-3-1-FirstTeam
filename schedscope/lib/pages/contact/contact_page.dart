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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String name = '';
        String number = '';
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '이름'),
                  onChanged: (value) => name = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: '전화번호'),
                  onChanged: (value) => number = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && number.isNotEmpty) {
                      setState(() {
                        contacts.add({'name': name, 'number': number});
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
          ),
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
            color: Color(0xFF0F1828),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFF0F1828)),
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
              subtitle: Text(
                contact['number']!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
