import 'package:apps/design/colors.dart';
import 'package:apps/design/styles.dart';
import 'package:apps/pages/menu/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:apps/services/fake_auth_service.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../utils/navigator_helper.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = FakeAuthService(); // Инициализируем сервис
  bool _isLoading = false; // Состояние загрузки

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        _isLoading = true; // Начинаем загрузку
      });

      String? token = await apiService.login(
        _phoneController.text,
        _passwordController.text,
      );


      setState(() {
        _isLoading = false; // Заканчиваем загрузку
      });

      if (token != null) {
        await authStateService.login();
        NavigatorHelper.navigateToReplacement(context, const MenuPage());
      } else {
        // Показываем сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка входа. Проверьте данные или сервер.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(context), // Используем фоновый цвет
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Логотип или заголовок входа
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

                // Поле ввода номера телефона
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style:
                      listItem1Style(context),
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    labelStyle: listItem2Style(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        // Используем ваш secondaryColor, который темнее и контрастнее
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
                        ), // Скругляем углы
                      ),
                      elevation: 4.0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            // Показываем индикатор загрузки
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
