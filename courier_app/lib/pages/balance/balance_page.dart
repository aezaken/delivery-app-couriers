import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:flutter/material.dart';
import 'balance_list.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor(context),
        elevation: 0.06,
        centerTitle: true,
        title: Text(
          'Баланс',
          style: primaryTextStyle(context),
        ),

      ),
      body: Container(color: backgroundColor(context),
          child:
              BalanceList(),
            ),
      );
  }
}
