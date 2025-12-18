
import 'package:courier_app/pages/balance/history/history_list.dart';
import 'package:flutter/material.dart';

import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor(context),
        elevation: 0.06,
        centerTitle: true,
        title: Text(
          'История заказов',
          style: primaryTextStyle(context),
        ),

      ),
      body: Container(color: backgroundColor(context),
        child:
        HistoryList(),
      ),
    );
  }
}
