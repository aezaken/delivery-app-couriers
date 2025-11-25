import 'package:apps/design/styles.dart';
import 'package:flutter/material.dart';

class BalanceButtons extends StatelessWidget {
  final String balanceLabelText;
  const BalanceButtons({super.key, required this.balanceLabelText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(balanceLabelText, style: listItem1Style(context))],
    );
  }
}
