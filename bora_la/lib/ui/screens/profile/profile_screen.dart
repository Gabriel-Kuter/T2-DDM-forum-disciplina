import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Center(
        child: Text('Não foi possível carregar os dados do usuário.'),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              child: Text(
                user.nickname?.substring(0, 1).toUpperCase() ??
                    user.nome.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                    fontSize: 40, color: AppConstants.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Center(
            child: Text(
              user.nickname ?? user.nome,
              style: AppConstants.heading2,
            ),
          ),
          Center(
            child: Text(
              user.email,
              style: AppConstants.caption,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Perfil'),
            onTap: () {
              // TODO: Navegar para a edit_profile_screen.dart
              print('Navegar para a tela de edição de perfil');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('Versão do App'),
            subtitle: Text(AppConstants.appVersion),
          ),
        ],
      ),
    );
  }
}