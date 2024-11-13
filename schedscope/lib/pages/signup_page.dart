import 'package:flutter/material.dart';
import '../widgets/themed_input.dart';

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
      appBar: AppBar(),
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
              ElevatedButton(
                key: const Key('signup_button'),
                onPressed: () {
                  // 가입 로직 추가
                },
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
