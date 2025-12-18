import 'package:shared_data/models/order.dart';
import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:courier_app/pages/auth/login_page.dart';
import 'package:courier_app/providers/theme_provider.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:courier_app/utils/navigator_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SettingsPage extends StatelessWidget {
  // --- ИЗМЕНЕНИЕ: Принимаем информацию об активном заказе ---
  final Order? activeOrder;

  const SettingsPage({super.key, this.activeOrder});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkModeEnabled = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: AppBar(
        title: Text('Настройки', style: primaryTextStyle(context)),
        backgroundColor: surfaceColor(context),
        elevation: 0.06,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[

          ListTile(
            tileColor: surfaceColor(context),
            title: Text('Темная тема', style: listItem1Style(context)),
            subtitle: Text('Включить темный режим интерфейса', style: listItem2Style(context)),
            trailing: Switch(
              value: isDarkModeEnabled,
              activeThumbColor: primaryColor(context),
              onChanged: (bool value) {
                themeProvider.toggleTheme(value);
              },
            ),
            onTap: () {
              themeProvider.toggleTheme(!isDarkModeEnabled);
            },
          ),
          Divider(height: 1, color: backgroundColor(context)),

          ListTile(
            tileColor: surfaceColor(context),
            title: Text('Проверить соединение', style: listItem1Style(context)),
            subtitle: Text('Отправить тестовый запрос на сервер', style: listItem2Style(context)),
            onTap: () => _testConnection(context),
          ),
          Divider(height: 1, color: backgroundColor(context)),

          ListTile(
            tileColor: surfaceColor(context),
            title: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              // --- ИЗМЕНЕНИЕ: Передаем заказ в функцию выхода ---
              _logout(context, activeOrder);
            },
          ),
          Divider(height: 1, color: backgroundColor(context)),
        ],
      ),
    );
  }

  void _testConnection(BuildContext context) async {
    final apiService = context.read<ApiService>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Проверка соединения...')),
    );

    final isConnected = await apiService.testDbConnection();

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConnected
              ? 'Соединение с сервером успешно!'
              : 'Ошибка: не удалось подключиться к серверу.',
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
      ),
    );
  }

  // --- ИЗМЕНЕНИЕ: Добавляем проверку перед выходом ---
  void _logout(BuildContext context, Order? activeOrder) async {
    if (activeOrder != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала завершите или отмените активный заказ!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await authStateService.logout();
    NavigatorHelper.navigateToReplacement(context, const LoginPage());
  }
}