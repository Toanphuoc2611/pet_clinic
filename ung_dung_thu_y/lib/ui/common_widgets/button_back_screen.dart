import 'package:flutter/material.dart';

class ButtonBackScreen extends StatelessWidget {
  final VoidCallback? onPress;
  const ButtonBackScreen({this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPress, icon: Icon(Icons.arrow_back));
  }
}
