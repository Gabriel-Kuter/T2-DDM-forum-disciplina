import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nicknameController.text = user.nickname ?? '';
      _avatarUrlController.text = user.avatarUrl ?? '';
    }

    _nicknameController.addListener(_onFieldChanged);
    _avatarUrlController.addListener(_onFieldChanged);
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profileHasChanges = _nicknameController.text.trim() != (user.nickname ?? '') ||
        _avatarUrlController.text.trim() != (user.avatarUrl ?? '');

    final passwordHasChanges = _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;

    final hasChanges = profileHasChanges || passwordHasChanges;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('Usuário não encontrado');
      }

      if (_newPasswordController.text.isNotEmpty) {
        final passwordUpdateSuccess = await authProvider.updatePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (!passwordUpdateSuccess) {
          throw Exception(authProvider.errorMessage ?? 'Erro ao atualizar senha');
        }
      }

      final profileHasChanges = _nicknameController.text.trim() != (currentUser.nickname ?? '') ||
          _avatarUrlController.text.trim() != (currentUser.avatarUrl ?? '');

      if (profileHasChanges) {
        final updatedUser = currentUser.copyWith(
          nickname: _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isEmpty
              ? null
              : _avatarUrlController.text.trim(),
        );

        final profileUpdateSuccess = await authProvider.updateProfile(updatedUser);

        if (!profileUpdateSuccess) {
          throw Exception(authProvider.errorMessage ?? 'Erro ao atualizar perfil');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Você tem alterações não salvas. Deseja realmente sair sem salvar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _handleSaveProfile,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Salvar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            if (user == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppConstants.errorColor,
                    ),
                    SizedBox(height: 16),
                    Text('Usuário não encontrado'),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                            backgroundImage: _avatarUrlController.text.trim().isNotEmpty
                                ? NetworkImage(_avatarUrlController.text.trim())
                                : null,
                            child: _avatarUrlController.text.trim().isEmpty
                                ? Text(
                              (_nicknameController.text.trim().isNotEmpty
                                  ? _nicknameController.text
                                  : user.nome)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXLarge),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações do Sistema',
                              style: AppConstants.heading3,
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            _buildInfoRow('Nome Completo', user.nome),
                            _buildInfoRow('Email', user.email),
                            _buildInfoRow('Matrícula/CPF', user.matricula),
                            _buildInfoRow('Tipo de Conta',
                                user.role == AppConstants.roleStudent ? 'Aluno' : 'Professor'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações Editáveis',
                              style: AppConstants.heading3,
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),

                            TextFormField(
                              controller: _nicknameController,
                              enabled: !_isLoading,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Apelido (Opcional)',
                                hintText: 'Como você quer ser chamado?',
                                prefixIcon: Icon(Icons.tag),
                                helperText: 'Deixe vazio para usar seu nome completo',
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (value.trim().length < 2) {
                                    return 'Apelido deve ter pelo menos 2 caracteres';
                                  }
                                  if (value.trim().length > 50) {
                                    return 'Apelido deve ter no máximo 50 caracteres';
                                  }
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppConstants.paddingMedium),

                            TextFormField(
                              controller: _avatarUrlController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.url,
                              decoration: const InputDecoration(
                                labelText: 'URL do Avatar (Opcional)',
                                hintText: 'https://exemplo.com/minha-foto.jpg',
                                prefixIcon: Icon(Icons.image),
                                helperText: 'Link para sua foto de perfil',
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final uri = Uri.tryParse(value.trim());
                                  if (uri == null || !uri.hasAbsolutePath) {
                                    return 'URL inválida';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingLarge),

                    Card(
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            'Alterar Senha',
                            style: AppConstants.heading3,
                          ),
                          subtitle: const Text('Clique para alterar sua senha'),
                          leading: const Icon(Icons.lock),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isChangingPassword = expanded;
                              if (!expanded) {
                                // Limpar campos quando colapsar
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingLarge),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _currentPasswordController,
                                    enabled: !_isLoading,
                                    obscureText: _obscureCurrentPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Senha Atual',
                                      hintText: 'Digite sua senha atual',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureCurrentPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureCurrentPassword = !_obscureCurrentPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_newPasswordController.text.isNotEmpty ||
                                          _confirmPasswordController.text.isNotEmpty) {
                                        if (value == null || value.isEmpty) {
                                          return 'Senha atual é obrigatória para alterar senha';
                                        }
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: AppConstants.paddingMedium),

                                  TextFormField(
                                    controller: _newPasswordController,
                                    enabled: !_isLoading,
                                    obscureText: _obscureNewPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Nova Senha',
                                      hintText: 'Digite a nova senha',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureNewPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword = !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_currentPasswordController.text.isNotEmpty ||
                                          _confirmPasswordController.text.isNotEmpty) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nova senha é obrigatória';
                                        }
                                        if (value.length < 6) {
                                          return 'Nova senha deve ter pelo menos 6 caracteres';
                                        }
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: AppConstants.paddingMedium),

                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    enabled: !_isLoading,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar Nova Senha',
                                      hintText: 'Digite a nova senha novamente',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_currentPasswordController.text.isNotEmpty ||
                                          _newPasswordController.text.isNotEmpty) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirmação de senha é obrigatória';
                                        }
                                        if (value != _newPasswordController.text) {
                                          return 'Senhas não coincidem';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXLarge),

                    ElevatedButton(
                      onPressed: _hasChanges && !_isLoading ? _handleSaveProfile : null,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(_hasChanges ? 'Salvar Alterações' : 'Nenhuma Alteração'),
                    ),

                    if (_hasChanges) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      OutlinedButton(
                        onPressed: _isLoading ? null : () {
                          _nicknameController.text = user.nickname ?? '';
                          _avatarUrlController.text = user.avatarUrl ?? '';
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          setState(() {
                            _isChangingPassword = false;
                          });
                        },
                        child: const Text('Restaurar'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppConstants.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}