import 'package:shared_ui/colors.dart';
import 'package:courier_app/pages/balance/balance_buttons.dart';
import 'package:flutter/material.dart';

class BalanceItem extends StatelessWidget {
  final Function() onTap;
  final String balanceButtonText;
  const BalanceItem({
    super.key,
    required this.onTap,
    required this.balanceButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Card(
        color: surfaceColor(context),
        margin: EdgeInsets.zero,
        elevation: 0.1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: BalanceButtons(balanceLabelText: balanceButtonText),
          ),
        ),
      ),
    );
  }
}
