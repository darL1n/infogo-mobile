import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isGoogleLoading = false;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPhoneLogin() {
    context.push('/login/phone');
  }

  void _openEmailLogin() {
    context.push('/login/email');
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      await _authService.loginWithGoogle();
      await context.read<UserProvider>().login();
      context.go('/profile');
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseLayout(
      title: "Вход",
      showBackButton: true,
      showBottomNavigation: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Добро пожаловать 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Выберите удобный способ входа. Мы используем данные только для авторизации и не рассылаем спам.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),

              /// ── Блок "Вход по коду" ────────────────────────────────
              Text(
                'Вход по коду',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CustomButton(text: "По email", onPressed: _openEmailLogin),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: "По номеру телефона",
                      onPressed: _openPhoneLogin,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ── Разделитель "или" ────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'или',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              /// ── Блок "Быстрый вход" / Google ─────────────────────
              Text(
                'Быстрый вход',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // тут можно заменить на OutlinedButton.icon, если не хочешь трогать CustomButton
                    CustomButton(
                      text: "Войти через Google",
                      onPressed: _isGoogleLoading ? null : _loginWithGoogle,
                      isLoading: _isGoogleLoading,

                      // белая кнопка с тёмным текстом
                      color: Colors.white,
                      disabledColor: Colors.grey.shade200,
                      textColor: Colors.black87,
                      disabledTextColor: Colors.black45,

                      // тонкий серый бордер
                      border: BorderSide(color: Colors.grey.shade300),

                      // иконка слева
                      leading: Image.asset(
                        'assets/icons/google.png', // добавишь этот файл в assets
                        width: 20,
                        height: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Мы не получаем доступ к вашему паролю и ничего не публикуем от вашего имени.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
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
