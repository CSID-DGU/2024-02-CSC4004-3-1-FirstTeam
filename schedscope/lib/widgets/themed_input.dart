import 'package:flutter/material.dart';

/// 스타일이 적용된 사용자 입력 필드
class ThemedInput extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final TextEditingController controller;
  final Widget? suffixIcon;

  const ThemedInput({
    super.key,
    required this.labelText,
    this.obscureText = false,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF999999)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
