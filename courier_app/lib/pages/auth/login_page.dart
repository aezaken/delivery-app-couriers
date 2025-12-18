import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:shared_data/models/login_response.dart';
import 'package:courier_app/pages/menu/menu_page.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:courier_app/main.dart';
import 'package:courier_app/utils/navigator_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final apiService = context.read<ApiService>();

      try {
        final loginResponse = await apiService.login(
          _phoneController.text,
          _passwordController.text,
        );

        if (loginResponse != null) {
          // --- НАЧАЛО НОВОЙ ЛОГИКИ ---
          // После успешного входа, получаем и отправляем FCM токен
          final fcmToken = await notificationService.getToken();
          if (fcmToken != null) {
            await apiService.updateFcmToken(fcmToken);
          }
          // --- КОНЕЦ НОВОЙ ЛОГИКИ ---

          await authStateService.login();

          if (mounted) {
            NavigatorHelper.navigateToReplacement(context, const MenuPage());
          }
        } else {
          _showErrorSnackBar('Неверные учетные данные.');
        }
      } catch (e) {
        _showErrorSnackBar('Ошибка входа: ${e.toString()}');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Курьеры',
                  style: primaryTextStyle(context).copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Вход в систему', style: listItem2Style(context)),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: listItem1Style(context),
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    labelStyle: listItem2Style(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: secondaryColor(context).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    fillColor: surfaceColor(context),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: primaryColor(context),
                        width: 2.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите номер телефона';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: listItem1Style(context),
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: listItem2Style(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: secondaryColor(context).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    fillColor: surfaceColor(context),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: primaryColor(context),
                        width: 2.0,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите пароль';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),


                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      primaryColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ), 
                      ),
                      elevation: 4.0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                      color: secondaryColor(context),
                    )
                        : Text(
                      'Войти',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                        secondaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
