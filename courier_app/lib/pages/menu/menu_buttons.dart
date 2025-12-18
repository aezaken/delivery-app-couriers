import 'package:shared_ui/styles.dart';
import 'package:flutter/material.dart';

class MenuButtons extends StatelessWidget {
  final String menuLabelText;
  const MenuButtons({super.key, required this.menuLabelText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(menuLabelText, style: listItem1Style(context))],
    );
  }
}
