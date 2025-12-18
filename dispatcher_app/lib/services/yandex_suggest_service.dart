import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;
import 'package:yandex_maps_mapkit/search.dart' as yandex;
import '../models/suggestion.dart';

class YandexSuggestService {
  static YandexSuggestService? _instance;

  static yandex.SearchManager? _manager;
  static bool _isFirstRequest = true;

  // 🔑 Ключ API
  static const String _apiKey = 'ae50d4c9-5276-4ee6-ab50-60640b8b3ccf';

  YandexSuggestService._();

  static Future<YandexSuggestService> create() async {
    if (_instance == null) {
      await WidgetsBinding.instance.endOfFrame;
      final search = yandex.SearchFactory.instance;
      _manager = search.createSearchManager(yandex.SearchManagerType.Online);
      _instance = YandexSuggestService._();
      print('✅ YandexSuggestService: создан');
    }
    return _instance!;
  }

  // 🔁 Возвращаем List<Suggestion>, а не SuggestItem
  Future<List<Suggestion>> getSuggestions({
    required String text,
    required mapkit.BoundingBox boundingBox,

    yandex.SuggestOptions? suggestOptions,
  }) async {
    if (text.length < 2) return [];

    final options = suggestOptions ?? yandex.SuggestOptions();

    if (_isFirstRequest) {
      print('🟡 Первый запрос — ждём 300 мс для стабилизации MapKit');
      await Future.delayed(Duration(milliseconds: 300));
      _isFirstRequest = false;
    }

    // Сначала пробуем нативный способ
    try {
      final nativeItems = await _performNativeSuggest(
        text: text,
        window: boundingBox,
        suggestOptions: options,
      );
      return nativeItems.map(_toSuggestion).toList();
    } on TimeoutException {
      print('❌ Нативный suggest: таймаут — переключаемся на HTTP');
    } on Exception catch (e) {
      print('❌ Нативный suggest: ошибка — $e');
    }

    // Если не получилось — HTTP
    print('🔁 Используем HTTP-обход');
    return await _performHttpSuggest(
      text: text,
      window: boundingBox,
    );
  }

  Future<List<yandex.SuggestItem>> _performNativeSuggest({
    required String text,
    required mapkit.BoundingBox window,
    required yandex.SuggestOptions suggestOptions,
  }) async {
    final completer = Completer<List<yandex.SuggestItem>>();
    final session = _manager!.createSuggestSession();

    final listener = yandex.SearchSuggestSessionSuggestListener(
      onResponse: (suggestResponse) {
        if (!completer.isCompleted) {
          print('✅ NATIVE: ${suggestResponse.items.length} подсказок');
          completer.complete(suggestResponse.items);
        }
        session.reset();
      },
      onError: (error) {
        if (!completer.isCompleted) {
          print('❌ NATIVE ERROR: $error');
          completer.completeError(error);
        }
        session.reset();
      },
    );

    try {
      session.suggest(window, suggestOptions, listener, text: text);
    } catch (e) {
      if (!completer.isCompleted) {
        print('❌ NATIVE EXCEPTION: $e');
        completer.completeError(e);
      }
      session.reset();
    }

    return completer.future.timeout(Duration(seconds: 15));
  }

  Future<List<Suggestion>> _performHttpSuggest({
    required String text,
    required mapkit.BoundingBox window,
  }) async {
    final centerLon = (window.southWest.longitude + window.northEast.longitude) / 2;
    final centerLat = (window.southWest.latitude + window.northEast.latitude) / 2;

    final url = Uri.https('suggest-maps.yandex.net', '/suggest-geo', {
      'text': text,
      'origin': 'flutter-debug',
      'll': '$centerLon,$centerLat',
      'spn': '0.5,0.5',
      'apikey': _apiKey,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = response.body.trim();

        if (body.startsWith('suggest.apply(')) {
          // 🔧 Просто убираем обёртку — не пытаемся парсить как JSON
          final dataStr = body
              .replaceFirst('suggest.apply(', '')
              .replaceFirst(');', '')
              .trim();

          // 🛠️ Вручную ищем массив подсказок: ["maps", [...]]
          // Это грубовато, но безопасно
          final suggestions = <Suggestion>[];

          // Ищем паттерн: [["maps",["текст",["hl","Пушкина"],"..."]]]
          final regExp = RegExp(r'\["maps",\[(.*?)\]\]');
          final matches = regExp.allMatches(dataStr);

          for (var match in matches) {
            final content = match.group(1);
            if (content == null) continue;

            // Извлекаем части: ["улица ",["hl","Пушкина"],", Уссурийск..."]
            // Убираем квадратные скобки и разбиваем по '],['
            final parts = content.split('],[].');

            // Собираем текст
            final textParts = <String>[];
            for (var part in parts) {
              // Убираем кавычки и лишние символы
              final clean = part.replaceAll(RegExp(r'^"|"$'), '').trim();
              if (clean.isNotEmpty && !clean.startsWith('["hl') && !clean.endsWith('"]')) {
                textParts.add(clean);
              } else if (clean.startsWith('["hl') && clean.endsWith('"]')) {
                // Извлекаем текст из ["hl","Пушкина"]
                final hlMatch = RegExp(r'\["hl","(.*?)"\]').firstMatch(clean);
                if (hlMatch != null) {
                  textParts.add(hlMatch.group(1)!);
                }
              }
            }

            final fullText = textParts.join('');
            suggestions.add(Suggestion(
              displayText: text,
              searchText: fullText,
              subtitle: fullText,
            ));
          }

          print('✅ HTTP: получено ${suggestions.length} подсказок (вручную)');
          return suggestions;
        }
      } else {
        print('❌ HTTP: статус ${response.statusCode}');
      }
    } catch (e) {
      print('❌ HTTP: ошибка парсинга — $e');
    }

    return [];
  }

  Suggestion _toSuggestion(yandex.SuggestItem item) {
    return Suggestion(
      displayText: item.displayText ?? item.searchText,
      searchText: item.searchText,
      subtitle: item.subtitle?.text ?? '',
    );

  }

  void close() {
    _instance = null;
  }

  static void closeInstance() {
    _instance?.close();
  }
}