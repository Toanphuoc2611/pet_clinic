import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onPress;
  const MyAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('$title', style: TextStyle(fontSize: 16)),
        content: Text('$message', style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          TextButton(onPressed: onPress, child: const Text('OK')),
        ],
      ),
    );
  }
}
