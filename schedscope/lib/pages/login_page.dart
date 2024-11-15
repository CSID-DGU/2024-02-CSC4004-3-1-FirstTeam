import 'package:flutter/material.dart';
import '../widgets/themed_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 비밀번호 표시/숨김 토글
  bool _obscureText = true;
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
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
                  Navigator.pushNamed(context, '/signup');
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
