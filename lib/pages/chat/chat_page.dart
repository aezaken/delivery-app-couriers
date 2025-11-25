import 'package:apps/design/colors.dart';
import 'package:apps/design/styles.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String? orderNumber;

  const ChatPage({super.key, this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor(context),
      appBar: AppBar(
        backgroundColor: surfaceColor(context),
        elevation: 0.06,
        centerTitle: true,
        title: Text('Чат с диспетчером', style: primaryTextStyle(context)),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          if (orderNumber != null)
              Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              color: primaryOpacyColor(context), // Используем ваш цвет
              child: Text(
                'Обсуждается заказ №$orderNumber',
                textAlign: TextAlign.center,
                style: listItem2Style(context).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          // Область сообщений (заглушка)
          Expanded(
            child: Center(
              child: Text(
                'Здесь будут сообщения чата',
                style: listItem2Style(context),
              ),
            ),
          ),
          // Поле ввода сообщения
          SafeArea(
              child: _buildMessageInput(context)
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Введите сообщение...',
                fillColor: surfaceColor(context),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () {
              // Логика отправки сообщения
            },
            backgroundColor: primaryColor(context),
            mini: true,
            child: Icon(Icons.send, color: secondaryColor(context)),
          ),
        ],
      ),
    );
  }
}