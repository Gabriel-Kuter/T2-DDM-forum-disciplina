import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success && mounted) {
      _showErrorSnackBar(
        authProvider.errorMessage ?? 'Erro ao fazer login. Tente novamente.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final isLoading =
                  authProvider.status == AuthStatus.authenticating;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingXLarge),

                  Icon(Icons.forum, size: 80, color: AppConstants.primaryColor),
                  const SizedBox(height: AppConstants.paddingMedium),

                  Text(
                    AppConstants.appName,
                    style: AppConstants.heading1,
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    'Faça login para continuar',
                    style: AppConstants.caption,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.paddingXLarge),

                  Card(
                    color: AppConstants.cardColor,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Entrar',
                              style: AppConstants.heading2,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AppConstants.paddingLarge),

                            if (authProvider.errorMessage != null && !isLoading)
                              Container(
                                padding: const EdgeInsets.all(
                                  AppConstants.paddingMedium,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: AppConstants.paddingMedium,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.errorColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusMedium,
                                  ),
                                  border: Border.all(
                                    color: AppConstants.errorColor.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppConstants.errorColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.errorMessage!,
                                        style: TextStyle(
                                          color: AppConstants.errorColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      color: AppConstants.errorColor,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        authProvider.clearError();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !isLoading,
                              decoration: AppConstants.getInputDecoration(
                                labelText: 'Email',
                                hintText: 'Digite seu email',
                                prefixIcon: Icons.email,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppConstants.emailRequiredMessage;
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return AppConstants.emailInvalidMessage;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppConstants.paddingMedium),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              enabled: !isLoading,
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: AppConstants.getInputDecoration(
                                labelText: 'Senha',
                                hintText: 'Digite sua senha',
                                prefixIcon: Icons.lock,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppConstants.passwordRequiredMessage;
                                }
                                if (value.length < 6) {
                                  return AppConstants.passwordMinLengthMessage;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppConstants.paddingLarge),

                            ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(),
                                      )
                                      : const Text('Entrar'),
                            ),

                            const SizedBox(height: AppConstants.paddingMedium),

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppConstants.textSecondaryColor
                                        .withValues(alpha: 0.3),
                                    height: AppConstants.paddingLarge,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingMedium,
                                  ),
                                  child: Text(
                                    'ou',
                                    style: AppConstants.caption,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppConstants.textSecondaryColor
                                        .withValues(alpha: 0.3),
                                    height: AppConstants.paddingLarge,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.paddingMedium),

                            TextButton(
                              onPressed: isLoading ? null : _navigateToSignup,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppConstants.paddingMedium,
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: AppConstants.bodyText,
                                  children: [
                                    const TextSpan(text: 'Não tem uma conta? '),
                                    TextSpan(
                                      text: 'Cadastre-se',
                                      style: TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.paddingLarge),

                  Text(
                    'v${AppConstants.appVersion}',
                    style: AppConstants.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
