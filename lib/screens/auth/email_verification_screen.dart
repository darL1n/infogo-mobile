import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;       // загрузка "Подтвердить код"
  bool _isResending = false;     // загрузка "Отправить код ещё раз"
  String _otpCode = "";

  // таймер повторной отправки
  static const int _resendTimeout = 30; // сек, синхронно с backend spam_timeout
  int _secondsLeft = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer(); // как только зашли на экран — блокируем ресенд на 30 сек
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _secondsLeft = _resendTimeout);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verifyEmailCode() async {
    setState(() => _isLoading = true);
    try {
      final code = int.tryParse(_otpCode);
      if (code == null) {
        _showSnackbar('Неверный формат кода');
        setState(() => _isLoading = false);
        return;
      }

      await _authService.verifyEmailCode(widget.email, code);
      await context.read<UserProvider>().login();
      context.go('/profile');
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_secondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      await _authService.sendEmailCode(widget.email);
      _showSnackbar(
        'Новый код отправлен на ${_maskedEmail(widget.email)}',
      );
      _startResendTimer();
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) return '**@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BaseLayout(
      title: "Подтверждение кода",
      showBackButton: true,
      showBottomNavigation: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Введите код из письма',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Мы отправили одноразовый код из 5 цифр на адрес '
                '${_maskedEmail(widget.email)}.\n'
                'Код действует несколько минут, затем его нужно будет запросить заново.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    PinCodeTextField(
                      appContext: context,
                      length: 5, // 👈 код именно из 5 цифр
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
                        activeFillColor: theme.cardColor,
                        inactiveFillColor: theme.cardColor,
                        selectedFillColor: theme.cardColor,
                        activeColor: scheme.primary,
                        inactiveColor: Colors.grey.shade400,
                        selectedColor: scheme.primary,
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
                    const SizedBox(height: 12),
                    Text(
                      'Проверь папку «Спам», если письмо долго не приходит.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔁 Блок "Отправить код ещё раз"
                    if (_secondsLeft > 0)
                      Text(
                        'Отправить код ещё раз через $_secondsLeft сек.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isResending ? null : _resendCode,
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Отправить код ещё раз'),
                      ),

                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Подтвердить код",
                            onPressed:
                                _otpCode.length == 5 ? _verifyEmailCode : null,
                            isDisabled: _otpCode.length != 5,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
