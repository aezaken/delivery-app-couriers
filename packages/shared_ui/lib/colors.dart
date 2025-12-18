import 'dart:ui';
import 'package:flutter/material.dart';

// Ваши исходные цвета (оставляем как базовую палитру)
const Color _primaryLightColor = Color(0xFFEFB12C);
const Color _primaryLightOpacyColor = Color(0xFFF7D99E);
const Color _secondaryLightColor = Color(0xFF20201E);
const Color _secondaryLightVariantColor = Color(0x8020201E);
const Color _backgroundLightColor = Color(0xffebebe9);
const Color _surfaceLightColor = Color(0xffffffff);

// Определим базовую палитру для темной темы (пример)
// Вам, возможно, захочется скорректировать эти цвета
const Color _backgroundDarkColor = Color(0xFF121212);
const Color _surfaceDarkColor = Color(0xFF1E1E1E);
const Color _secondaryDarkColor = Color(0xFFE0E0E0);
const Color _secondaryDarkVariantColor = Color(0x80E0E0E0);
// Основной цвет (primary) можно оставить тем же для обеих тем, он яркий
const Color _primaryDarkColor = Color(0xFFEFB12C);

Color primaryColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _primaryDarkColor : _primaryLightColor;

Color primaryOpacyColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _primaryDarkColor.withOpacity(0.5) : _primaryLightOpacyColor;

Color secondaryColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _secondaryDarkColor : _secondaryLightColor;

Color secondaryVariantColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _secondaryDarkVariantColor : _secondaryLightVariantColor;

Color backgroundColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _backgroundDarkColor : _backgroundLightColor;

Color surfaceColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? _surfaceDarkColor : _surfaceLightColor;