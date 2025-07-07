import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _matriculaController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      matricula: _matriculaController.text.trim(),
      nickname:
          _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessSnackBar(AppConstants.signupSuccessMessage);
      Navigator.of(context).pop();
    } else if (mounted) {
      _showErrorSnackBar(
        authProvider.errorMessage ?? 'Erro ao criar conta. Tente novamente.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }

  String? _validateCPF(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.matriculaRequiredMessage;
    }

    // Remove caracteres de formatação
    final cleanCPF = value.replaceAll(RegExp(r'[^\d]'), '');

    // Checa se tem 11 dígitos
    if (cleanCPF.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Checar se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanCPF)) {
      return 'CPF inválido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_add,
                size: 60,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              Text(
                'Cadastre-se',
                style: AppConstants.heading2,
                textAlign: TextAlign.center,
              ),

              Text(
                'Use seu CPF e email institucional para criar sua conta',
                style: AppConstants.caption,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

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
                        TextFormField(
                          controller: _matriculaController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: AppConstants.getInputDecoration(
                            labelText: 'Matrícula (CPF)',
                            hintText: 'Digite seu CPF',
                            prefixIcon: Icons.badge,
                          ),
                          validator: _validateCPF,
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: AppConstants.getInputDecoration(
                            labelText: 'Email Institucional',
                            hintText: 'seu.nome@edu.udesc.br',
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
                          controller: _nicknameController,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: AppConstants.getInputDecoration(
                            labelText: 'Apelido (Opcional)',
                            hintText: 'Como você quer ser chamado?',
                            prefixIcon: Icons.tag,
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
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

                        const SizedBox(height: AppConstants.paddingMedium),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          onFieldSubmitted: (_) => _handleSignup(),
                          decoration: AppConstants.getInputDecoration(
                            labelText: 'Confirmar Senha',
                            hintText: 'Digite sua senha novamente',
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirmação de senha é obrigatória';
                            }
                            if (value != _passwordController.text) {
                              return 'Senhas não coincidem';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.paddingLarge),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignup,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                  : const Text('Criar Conta'),
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: RichText(
                            text: TextSpan(
                              style: AppConstants.bodyText,
                              children: [
                                const TextSpan(text: 'Já tem uma conta? '),
                                TextSpan(
                                  text: 'Fazer login',
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
            ],
          ),
        ),
      ),
    );
  }
}
