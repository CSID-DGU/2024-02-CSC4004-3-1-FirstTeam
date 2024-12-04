import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16), // 제목 텍스트 크기 조정
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(content, textAlign: TextAlign.center),
        ],
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: onConfirm,
            child: const Text('확인'),
          ),
        ),
      ],
    );
  }
}
