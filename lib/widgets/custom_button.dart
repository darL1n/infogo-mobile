import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  final Color color;
  final Color disabledColor;
  final Color textColor;
  final Color disabledTextColor;
  final double height;
  final double width;
  final double borderRadius;

  /// 🆕 Иконка/любой виджет слева от текста
  final Widget? leading;

  /// 🆕 Бордер (например, для белой Google-кнопки)
  final BorderSide? border;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.color = Colors.blueAccent,
    this.disabledColor = Colors.grey,
    this.textColor = Colors.white,
    this.disabledTextColor = Colors.white70,
    this.height = 50,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.leading,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool buttonDisabled = isLoading || isDisabled;

    Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      );
    } else {
      // Если есть leading — делаем Row, иначе просто Text
      if (leading != null) {
        child = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            leading!,
            const SizedBox(width: 8),
            // 👇 текст теперь умеет сжиматься и обрезаться
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: buttonDisabled ? disabledTextColor : textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      } else {
        child = Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: buttonDisabled ? disabledTextColor : textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: buttonDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonDisabled ? disabledColor : color,
          foregroundColor: buttonDisabled ? disabledTextColor : textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: border ?? BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}
