import 'package:flutter/material.dart';
import 'schedule.dart';
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '연락처',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _appBarTitle = '연락처';

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

  Widget _buildContactsPage() {
    return Container(
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
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildSchedulePage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildContactsPage(),
      _buildEmptyPage('채팅 페이지'),
      _buildEmptyPage('설정 페이지'),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Color(0xFF0F1828),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFF0F1828)),
              onPressed: _addNewContact,
            ),
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.add_comment, color: Color(0xFF0F1828)), // 채팅방 추가 아이콘
              onPressed: () {
              },
            ),
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Color(0xFF0F1828)),
              onPressed: () {
                // Navigate to the SchedulePage when the calendar icon is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage()),
                );
              },
            ),

        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _appBarTitle = index == 0 ? '연락처' : index == 1 ? '채팅' : '설정';
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            activeIcon: CircleAvatar(
              backgroundColor: Color(0xFFE6F0FF),
              child: Icon(Icons.people, color: Color(0xFF0F1828)),
            ),
            label: '연락처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
            activeIcon: CircleAvatar(
              backgroundColor: Color(0xFFE6F0FF),
              child: Icon(Icons.chat_bubble, color: Color(0xFF0F1828)),
            ),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            activeIcon: CircleAvatar(
              backgroundColor: Color(0xFFE6F0FF),
              child: Icon(Icons.settings, color: Color(0xFF0F1828)),
            ),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
