import 'package:apps/design/colors.dart';
import 'package:apps/pages/menu/menu_page.dart';
import 'package:apps/providers/theme_provider.dart';
import 'package:apps/services/auth_state_service.dart';
import 'package:apps/utils/order_history_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'pages/auth/login_page.dart';
import 'services/location_service.dart';
import 'services/api_service.dart';

final NotificationService notificationService = NotificationService();
final AuthStateService authStateService = AuthStateService();
final LocationService locationService = LocationService();
final ApiService apiService = ApiService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await notificationService.initializePlatformNotifications();
  await authStateService.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    MultiProvider( // Используем MultiProvider для нескольких провайдеров
      providers: [
        ChangeNotifierProvider(create: (context) => OrderHistoryManager()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);

    // Добавляем FutureBuilder для определения стартового экрана
    return FutureBuilder<bool>(
      future: authStateService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final bool isLoggedIn = snapshot.data ?? false;
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Курьеры',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  // Используем динамические цвета здесь (если они функции)
                  primaryColor: primaryColor(context),
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  primaryColor: primaryColor(context),
                  brightness: Brightness.dark,
                ),
                themeMode: themeProvider.themeMode,

                // Определяем home на основе состояния входа
                home: isLoggedIn ? const MenuPage() : const LoginPage(),
              );
            },
          );
        } else {
          // Показываем экран загрузки (SplashScreen), пока проверяем статус входа
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}