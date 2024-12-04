import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/themed_input.dart';
import '../widgets/alert_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  /* 비밀번호 가리기/보이기 토글 함수 */
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /* 로그인 처리 함수 */
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    // Firebase Auth를 이용한 로그인
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home',
          (Route<dynamic> route) => false); // 로그인 성공 시 홈 화면으로 이동
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = '사용자를 찾을 수 없습니다.';
      } else if (e.code == 'wrong-password') {
        message = '잘못된 비밀번호입니다.';
      } else {
        message = '로그인에 실패했습니다.\n다시 시도해주세요.';
      }
      _showErrorDialog(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /* 오류 알림창 표시 함수 */
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* 앱 로고 이미지 */
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/1980/1980736.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 40),

              /* 이메일 입력 필드*/
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
              const SizedBox(height: 24),

              /* 로그인 버튼 */
              ElevatedButton(
                key: const Key('login_button'),
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('로그인', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),

              /* 회원가입 버튼 */
              OutlinedButton(
                key: const Key('signup_button'),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('회원가입', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
