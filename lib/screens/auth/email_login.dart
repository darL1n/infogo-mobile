import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_button.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';

class EmailLoginScreen extends StatefulWidget {
  final ValueChanged<String> onLoginSuccess;
  const EmailLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
  }

  Future<void> _sendEmailCode() async {
    if (!_isButtonEnabled) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    try {
      await _authService.sendEmailCode(email);
      widget.onLoginSuccess(email);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwipeBackWrapper(
      fallbackRoute: '/login',
      child: BaseLayout(
        title: "Вход по email",
        showBackButton: true,
        showBottomNavigation: false,
        fallbackRoute: '/login',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Укажи свою почту',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Отправим на неё одноразовый код из 5 цифр. '
                  'Код нужен только для входа и не используется для рассылок.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // карточка формы
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.mail_outline,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Мы используем email только для авторизации.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@mail.com',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          setState(() {
                            _isButtonEnabled = _isValidEmail(value.trim());
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Убедись, что у тебя есть доступ к этому адресу — '
                        'код придёт именно туда.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: "Получить код",
                        onPressed: _sendEmailCode,
                        isLoading: _isLoading,
                        isDisabled: !_isButtonEnabled,
                      ),
                    ],
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
    _emailController.dispose();
    super.dispose();
  }
}
