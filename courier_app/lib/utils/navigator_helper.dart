import 'package:flutter/material.dart';

class NavigatorHelper {

  static Future<void> navigateTo(BuildContext context, Widget nextPage) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return nextPage;
        },
      ),
    );
  }
  static Future<void> navigateToReplacement(BuildContext context, Widget nextPage) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return nextPage;
        },
      ),
    );
  }
}
