import 'package:flutter/material.dart';
import 'colors.dart';

TextStyle primaryTextStyle(BuildContext context) => TextStyle(
  color: primaryColor(context),
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

TextStyle listItem1Style(BuildContext context) => TextStyle(
  color: secondaryColor(context),
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

TextStyle listItem2Style(BuildContext context) => TextStyle(
  color: secondaryVariantColor(context),
  fontSize: 14,
  fontWeight: FontWeight.w600,
);