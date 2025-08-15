import 'package:flutter/material.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  const MyAppBar({required this.title, this.leading, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      backgroundColor: TColor.primary,
      foregroundColor: TColor.white,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
