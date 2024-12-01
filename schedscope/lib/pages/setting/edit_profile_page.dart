import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/themed_input.dart';
import '../../widgets/alert_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
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
          _nicknameController.text = userData['name'];
          _emailController.text = userData['email'];
        });
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Firestore의 사용자 정보 업데이트
      await FirebaseFirestore.instance
          .collection('User')
          .doc(_user!.uid)
          .update({
        'name': _nicknameController.text,
        'email': _emailController.text,
      });

      // Firebase Authentication의 이메일 업데이트
      await _user!.updateEmail(_emailController.text);

      Navigator.pop(context, true); // 프로필 수정 후 이전 페이지로 이동할 때 true 반환
    } catch (e) {
      _showErrorDialog('프로필 수정 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: '',
          content: message,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('프로필 수정',
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 22,
          //       fontWeight: FontWeight.w600,
          //     )),
          ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* 프로필 수정 텍스트 */
                    Text("프로필 수정",
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 50),

                    /* 닉네임 입력 필드 */
                    ThemedInput(
                      labelText: '닉네임',
                      controller: _nicknameController,
                    ),
                    const SizedBox(height: 16),

                    /* 이메일 입력 필드 */
                    ThemedInput(
                      labelText: '이메일',
                      controller: _emailController,
                    ),
                    const SizedBox(height: 24),

                    /* 수정하기 버튼 */
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            key: const Key('update_button'),
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text('수정하기',
                                style: TextStyle(fontSize: 16)),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
