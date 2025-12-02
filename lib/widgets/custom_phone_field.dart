import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function(bool) onValidationChanged;

  const CustomPhoneField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onValidationChanged,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  static const int maxPhoneLength = 9;
  bool _isValid = false;

  void _validateNumber(String phone) {
    if (phone.length > maxPhoneLength) {
      phone = phone.substring(0, maxPhoneLength);
      widget.controller.text = phone;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: phone.length),
      );
    }

    bool isValid = phone.length == maxPhoneLength;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
      widget.onValidationChanged(isValid);
    }

    // ✅ Теперь передаём номер вместе с `+998`
    widget.onChanged("+998$phone");
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.phone,
      textAlignVertical: TextAlignVertical.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxPhoneLength),
      ],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: "Номер телефона",
        labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/flags/uz.png', // ✅ Добавляем флаг Узбекистана
                width: 24,
                height: 16,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              const Text(
                "+998",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        counterText: "",
      ),
      onChanged: (phone) => _validateNumber(phone),
    );
  }
}
