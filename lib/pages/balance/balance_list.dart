
import 'package:apps/pages/balance/balance_item.dart';
import 'package:apps/pages/balance/history/history_page.dart';
import 'package:apps/utils/navigator_helper.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class BalanceList extends StatefulWidget {
  const BalanceList({super.key});

  @override
  State<BalanceList> createState() => _BalanceListState();
}

class _BalanceListState extends State<BalanceList> {
  List balanceButtonLabels = [
    'Вывести',
    'История заказов',
    'Штрафы',
  ];
  int balanceScore = 300;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [_list()]);
  }

  Widget _list() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _balance()),
        SliverList.builder(
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: BalanceItem(
                  balanceButtonText: balanceButtonLabels[index],
                  onTap: () {
                    _balanceDecrement();
                  },
                ),
              );
            }
            if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: BalanceItem(
                  balanceButtonText: balanceButtonLabels[index],
                  onTap: () {
                    NavigatorHelper.navigateTo(context, HistoryPage());
                  },
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: BalanceItem(
                    balanceButtonText: balanceButtonLabels[index],
                    onTap: () {}),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _balance() {
    return Column(
      children: [
        SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Ваш баланс:',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            Text(
              '$balanceScore ₽',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  void _balanceDecrement() {
    setState(() {
      balanceScore -= 100;
    });
  }
}
