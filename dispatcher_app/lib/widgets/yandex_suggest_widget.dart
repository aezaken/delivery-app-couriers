import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as yandex;
import 'package:dispatcher_app/services/yandex_suggest_service.dart';
import '../models/suggestion.dart';
import 'package:geolocator/geolocator.dart';

class YandexSuggestWidget extends StatefulWidget {
  final ValueChanged<String> onSuggestionSelected;
  final String hintText;

  const YandexSuggestWidget({
    Key? key,
    required this.onSuggestionSelected,
    required this.hintText,
  }) : super(key: key);

  @override
  State<YandexSuggestWidget> createState() => _YandexSuggestWidgetState();
}

class _YandexSuggestWidgetState extends State<YandexSuggestWidget> {
  final TextEditingController _controller = TextEditingController();
  List<Suggestion> _suggestions = [];
  bool _isLoading = false;
  String? _error;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      await YandexSuggestService.create();
      print('✅ YandexSuggestService получен');
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Ошибка: $e';
        });
      }
    }
  }

  void _onTextChanged(String query) {
    print('🟡 _onTextChanged: "$query"');

    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _searchSuggestions(query);
    });
  }

  Future<void> _searchSuggestions(String query) async {
    final boundingBox = yandex.BoundingBox(
      yandex.Point(latitude: 43.459344, longitude: 131.555522),
      yandex.Point(latitude: 43.983165, longitude: 132.331665),
    );

    setState(() {
      _isLoading = true;
      _suggestions = [];
      _error = null;
    });

    try {
      final service = await YandexSuggestService.create();
      final suggestions = await service.getSuggestions(
        text: query,
        boundingBox: boundingBox,
      );

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Ошибка: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            suffixIcon: _isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : null,
          ),
          onChanged: _onTextChanged,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            print('🔧 Тестовый запрос: "Пушкина"');
            _onTextChanged("Пушкина");
          },
          child: const Text("Тест: Пушкина"),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (_suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(
                    suggestion.displayText,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: suggestion.subtitle.isNotEmpty
                      ? Text(
                    suggestion.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                      : null,
                  onTap: () {
                    widget.onSuggestionSelected(suggestion.searchText);
                    _controller.text = suggestion.searchText;
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}