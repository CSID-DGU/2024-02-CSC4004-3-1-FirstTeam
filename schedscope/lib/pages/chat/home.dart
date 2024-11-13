import 'package:flutter/material.dart';

class ChatAppMainPage extends StatefulWidget {
  const ChatAppMainPage({super.key});

  @override
  _ChatAppMainPageState createState() => _ChatAppMainPageState();
}

class _ChatAppMainPageState extends State<ChatAppMainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('친구 목록', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('채팅', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('마이페이지', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  /// 상단 AppBar에 표시될 제목
  static const List<String> _titles = <String>[
    '연락처',
    '채팅',
    '설정',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '연락처',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3498DB),
        onTap: _onItemTapped,
      ),
    );
  }
}
