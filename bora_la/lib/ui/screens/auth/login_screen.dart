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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      _showErrorSnackBar(
        authProvider.errorMessage ?? 'Erro ao fazer login. Tente novamente.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          child: Column(
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

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
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
                          enabled: !_isLoading,
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
                          onPressed: _isLoading ? null : _handleLogin,
                          child:
                              _isLoading
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
                              child: Text('ou', style: AppConstants.caption),
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
                          onPressed: _isLoading ? null : _navigateToSignup,
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
          ),
        ),
      ),
    );
  }
}
