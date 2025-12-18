import 'package:flutter/material.dart';

class AnimatedContentSwitcher extends StatelessWidget {
  final bool showContent;
  final Widget orderWidget;

  const AnimatedContentSwitcher({
    Key? key,
    required this.showContent,
    required this.orderWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Мы сохраняем AnimatedSize, чтобы меню "прыгало", как вы и хотели.
    // Высота "прыжка" теперь будет зависеть только от размера виджета,
    // который мы передаем в orderWidget из menu_list.dart
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showContent ? 1.0 : 0.0,
        // SizedBox гарантирует, что контейнер схлопнется до нуля, когда контент не нужен,
        // что и вызывает анимацию "прыжка".
        child: SizedBox(
          width: double.infinity, // Занимаем всю ширину, чтобы избежать ошибок layout
          height: showContent ? null : 0.0,
          child: orderWidget,
        ),
      ),
    );
  }
}
