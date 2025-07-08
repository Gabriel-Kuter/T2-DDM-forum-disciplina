import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
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
                  Text('Não foi possível carregar os dados do usuário.'),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      backgroundImage: user.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl?.isEmpty != false
                          ? Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 40,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      user.displayName,
                      style: AppConstants.heading2,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      user.email,
                      style: AppConstants.caption,
                      textAlign: TextAlign.center,
                    ),
                    if (user.role == AppConstants.roleProfessor)
                      Container(
                        margin: const EdgeInsets.only(top: AppConstants.paddingSmall),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          border: Border.all(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school,
                              size: 16,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Professor',
                              style: AppConstants.caption.copyWith(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingXLarge),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nome Completo'),
                      subtitle: Text(user.nome),
                    ),
                    if (user.nickname?.isNotEmpty == true)
                      ListTile(
                        leading: const Icon(Icons.tag),
                        title: const Text('Apelido'),
                        subtitle: Text(user.nickname!),
                      ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('Matrícula/CPF'),
                      subtitle: Text(user.matricula),
                    ),
                    ListTile(
                      leading: Icon(
                        user.role == AppConstants.roleStudent
                            ? Icons.school_outlined
                            : Icons.school,
                      ),
                      title: const Text('Tipo de Conta'),
                      subtitle: Text(
                        user.role == AppConstants.roleStudent ? 'Aluno' : 'Professor',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Editar Perfil'),
                      subtitle: const Text('Alterar apelido e foto'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Versão do App'),
                      subtitle: Text(AppConstants.appVersion),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: AppConstants.errorColor,
                      ),
                      title: const Text(
                        'Sair',
                        style: TextStyle(color: AppConstants.errorColor),
                      ),
                      subtitle: const Text('Desconectar da conta'),
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza de que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().signOut();
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}