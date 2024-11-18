import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/alert_dialog.dart'; // CustomAlertDialog 위젯을 가져옴

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  User? _user;
  DocumentSnapshot<Map<String, dynamic>>? _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('User')
                .doc(_user!.uid)
                .get();
        setState(() {
          _userData = userData;
        });
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _confirmLogout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // 다이얼로그 외부를 터치하여 취소 가능
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '로그아웃',
          content: '정말 로그아웃 하시겠습니까?',
          onConfirm: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 50 * 1.5,
                      backgroundImage:
                          NetworkImage(_userData!['profile_image']),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _userData!['name'],
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 24 * 1.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userData!['email'],
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 16 * 1.5),
                    ),
                    const SizedBox(height: 24),

                    /* 버튼들을 스크롤뷰로 감쌈 */
                    Expanded(
                      child: ListView(
                        children: [
                          CustomButton(
                            icon: Icons.account_circle,
                            text: '프로필 수정',
                            onPressed: () {
                              // 프로필 수정 페이지로 이동
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.security,
                            text: '권한 관리',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.logout,
                            text: '로그아웃',
                            onPressed: _confirmLogout, // 로그아웃 확인 알림 추가
                          ),

                          /* 추가 버튼들 */
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.build,
                            text: '기타 항목 1',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.build,
                            text: '기타 항목 2',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.build,
                            text: '기타 항목 3',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.build,
                            text: '기타 항목 4',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            icon: Icons.build,
                            text: '기타 항목 5',
                            onPressed: () {
                              // 이동할 페이지 추가
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 45,
      padding: const EdgeInsets.symmetric(vertical: 8),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.grey), // 테두리 추가
      //   borderRadius: BorderRadius.circular(8), // 테두리 둥글게
      // ),
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF0F1828),
                    fontSize: 14 * 1.5,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Spacer(), // 남은 공간을 차지하여 우측 아이콘을 밀어냄
            const Icon(Icons.chevron_right, size: 24), // > 모양 아이콘
          ],
        ),
      ),
    );
  }
}
