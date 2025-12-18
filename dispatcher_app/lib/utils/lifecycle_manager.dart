import 'package:flutter/widgets.dart';

import '../services/yandex_suggest_service.dart';


class LifecycleManager extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // При выходе из приложения
    if (state == AppLifecycleState.detached) {
      print('🧹 Приложение закрывается — закрываем YandexSuggestService');
      YandexSuggestService.closeInstance();
    }
  }
}