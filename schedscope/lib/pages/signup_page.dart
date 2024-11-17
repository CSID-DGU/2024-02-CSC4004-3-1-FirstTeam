import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/themed_input.dart';
import '../widgets/alert_dialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      String message = '비밀번호가 일치하지 않습니다.';
      _showErrorDialog(message);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text('비밀번호가 일치하지 않습니다.'),
      //     backgroundColor: Theme.of(context).colorScheme.secondary,
      //   ),
      // );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nicknameController.text,
          'email': _emailController.text,
          'profile_image': '',
        });
        print("Firestore에 데이터 저장 완료"); //log
      } catch (e) {
        print("Firestore 저장 오류: $e"); //log
      }

      // 회원가입 성공 시 로그인 페이지로 이동
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = '비밀번호를 6자 이상 입력해주세요.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else {
        message = '회원가입에 실패했습니다.\n다시 시도해주세요.';
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog('서버와 통신 중 오류가 발생했습니다.');
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
        title: const Text('회원가입'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* 회원가입 텍스트 */
              Text("회원가입", style: Theme.of(context).textTheme.headlineLarge),
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
              const SizedBox(height: 16),

              /* 비밀번호 입력 필드 */
              ThemedInput(
                labelText: '비밀번호',
                controller: _passwordController,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 16),

              /* 비밀번호 확인 입력 필드 */
              ThemedInput(
                labelText: '비밀번호 확인',
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 24),

              /* 가입하기 버튼 */
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      key: const Key('signup_button'),
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('가입하기', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
