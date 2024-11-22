import 'package:flutter/material.dart';
import 'package:schedscope/pages/chat/chat_room_list.dart';
import 'setting/setting_page.dart';

class ChatAppMainPage extends StatefulWidget {
  const ChatAppMainPage({super.key});

  @override
  _ChatAppMainPageState createState() => _ChatAppMainPageState();
}

class _ChatAppMainPageState extends State<ChatAppMainPage> {
  int _selectedIndex = 0;

  // 페이지 별 위젯 연결
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text('친구 목록', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  //   Center(child: ChatRoomList());
  //   Center(child: SettingPage()), // setting_page.dart와 연결
  // ];

  static final List<Widget> _widgetOptions = <Widget>[
    const Text('친구 목록',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Center(child: ChatRoomList()),
    const Center(child: SettingPage()), // setting_page.dart와 연결
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
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 1.0,
          ),
        ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
