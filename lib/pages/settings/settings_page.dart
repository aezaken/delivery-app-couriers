import 'package:apps/design/colors.dart';
import 'package:apps/design/styles.dart';
import 'package:apps/pages/auth/login_page.dart';
import 'package:apps/providers/theme_provider.dart';
import 'package:apps/utils/navigator_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            title: const Text(
              'Выйти из аккаунта',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              _logout(context);
            },
          ),
          Divider(height: 1, color: backgroundColor(context)),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    await authStateService.logout();
    NavigatorHelper.navigateToReplacement(context, const LoginPage());
  }
}