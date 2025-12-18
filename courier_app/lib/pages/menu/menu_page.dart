
import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:courier_app/pages/menu/menu_list.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  void _sendSOS() {
    // В будущем здесь будет логика отправки сигнала на сервер
    // с текущими координатами курьера.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сигнал SOS отправлен диспетчеру!')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor(context),
        elevation: 0.06,
        centerTitle: true,
        title: Text('Меню', style: primaryTextStyle(context)),
      ),
      body: Container(color: backgroundColor(context), child: MenuList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendSOS,
        backgroundColor: Colors.redAccent,
        tooltip: 'Экстренный вызов SOS',
        child: const Icon(Icons.sos, color: Colors.white),
      ),// Используем динамический цвет
    );
  }
}