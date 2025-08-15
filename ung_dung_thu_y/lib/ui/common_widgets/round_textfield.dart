import 'package:flutter/material.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class RoundTitleTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final bool isRequire;
  final String hintText;
  final TextInputType? inputType;
  final bool obscureText;
  const RoundTitleTextfield({
    super.key,
    required this.hintText,
    this.controller,
    required this.title,
    this.obscureText = false,
    this.isRequire = true,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: TColor.secondText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            isRequire
                ? const Text(
                  "*",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: TColor.placholder,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
