import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_button.dart';
import 'package:mobile/widgets/custom_phone_field.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';

class PhoneLoginScreen extends StatefulWidget {
  /// Callback, который вызывается при успешной отправке кода.
  /// Параметром передаётся номер телефона.
  final ValueChanged<String> onLoginSuccess;
  const PhoneLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String _phoneNumber = "";
  bool _isButtonEnabled = false;

  Future<void> _sendAuthCode() async {
    if (!_isButtonEnabled) return;
    setState(() => _isLoading = true);
    try {
      await _authService.sendAuthCode(_phoneNumber);
      widget.onLoginSuccess(_phoneNumber);
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackWrapper(
      fallbackRoute: '/login',
      child: BaseLayout(
        title: "Вход по номеру",
        showBackButton: true,
        showBottomNavigation: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomPhoneField(
                  controller: _phoneController,
                  onChanged: (phone) => _phoneNumber = phone,
                  onValidationChanged: (isValid) {
                    setState(() => _isButtonEnabled = isValid);
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Получить код",
                  onPressed: _sendAuthCode,
                  isLoading: _isLoading,
                  isDisabled: !_isButtonEnabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
