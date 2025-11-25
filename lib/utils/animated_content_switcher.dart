import 'package:flutter/material.dart';

import '../design/colors.dart';

class AnimatedContentSwitcher extends StatelessWidget {
  final bool showContent;
  final bool isLoading;
  final Widget orderWidget;

  const AnimatedContentSwitcher({
    Key? key,
    required this.showContent,
    required this.isLoading,
    required this.orderWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: showContent ? 1.0 : 0.0,
        child: SizedBox(
          height: showContent ? null : 0.0,
          child: isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      right: 16,
                    ),
                    child: Column(
                      children: [
                        Text('Поиск заказа...', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 5,),
                        CircularProgressIndicator(color: primaryColor(context)),
                      ],
                    ),
                  ),
                )
              : orderWidget,
        ),
      ),
    );
  }
}
