import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String phone;

  /// Callback, вызываемый при успешной верификации

  const VerificationScreen({super.key, required this.phone});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _otpCode = "";

  Future<void> _verifyAuthCode() async {
    setState(() => _isLoading = true);
    try {
      final code = int.tryParse(_otpCode);
      if (code == null) {
        _showSnackbar('Неверный формат кода');
        setState(() => _isLoading = false);
        return;
      }
      await _authService.verifyAuthCode(widget.phone, code);
      await Provider.of<UserProvider>(context, listen: false).login();
      context.go('/profile');
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Подтверждение кода",
      showBackButton: true,
      showBottomNavigation: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Введите код из SMS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 55,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.deepPurple,
                  borderWidth: 2,
                ),
                enableActiveFill: true,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                onChanged: (value) {
                  setState(() => _otpCode = value);
                },
                onCompleted: (value) {
                  setState(() => _otpCode = value);
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                    text: "Подтвердить код",
                    onPressed: _otpCode.length == 6 ? _verifyAuthCode : null,
                    isDisabled: _otpCode.length != 6,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
