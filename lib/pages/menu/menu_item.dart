import 'package:apps/design/colors.dart';
import 'package:apps/pages/menu/menu_buttons.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final Function() onTap;
  final String menuButtonText;

  const MenuItem({super.key, required this.onTap, required this.menuButtonText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Card(
        color: surfaceColor(context),
        margin: EdgeInsets.zero,
        elevation: 0.06,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: MenuButtons(menuLabelText: menuButtonText),
          ),
        ),
      ),
    );
  }
}
