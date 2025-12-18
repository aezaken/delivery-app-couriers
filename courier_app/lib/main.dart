import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_ui/colors.dart';
import 'package:courier_app/pages/menu/menu_page.dart';
import 'package:courier_app/providers/theme_provider.dart';
import 'package:courier_app/services/auth_state_service.dart';
import 'package:courier_app/utils/order_history_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courier_app/services/notification_service.dart';
import 'package:courier_app/pages/auth/login_page.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

// --- НОВАЯ ЛОГИКА: Фоновый обработчик --- 
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");

  // Извлекаем ID заказа и сохраняем его в SharedPreferences
  final orderId = message.data['orderId'];
  if (orderId != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_order_id', orderId);
    print("Saved pending order ID: $orderId");
  }
}
// -------------------------------------

// Глобальные сервисы
final ApiService apiService = ApiService();
final NotificationService notificationService = NotificationService();
final AuthStateService authStateService = AuthStateService(apiService);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");

  await notificationService.initializePlatformNotifications();
  await authStateService.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => OrderHistoryManager()),
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
                  primaryColor: primaryColor(context),
                  brightness: Brightness.light,
                ),
                darkTheme: ThemeData(
                  primaryColor: primaryColor(context),
                  brightness: Brightness.dark,
                ),
                themeMode: themeProvider.themeMode,
                home: isLoggedIn ? const MenuPage() : const LoginPage(),
              );
            },
          );
        } else {
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
