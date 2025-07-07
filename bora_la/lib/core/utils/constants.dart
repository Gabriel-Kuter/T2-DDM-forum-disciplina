import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Fórum 65DDM';
  static const String appVersion = '1.0.0';

  static const String roleStudent = 'aluno';
  static const String roleProfessor = 'professor';

  // --- CORES ---
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  // --- PADDING ---
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // --- BORDER RADIUS ---
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  // --- ESTILOS DE TEXTO ---
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // --- MENSAGENS ---
  static const String emailRequiredMessage = 'Email é obrigatório';
  static const String emailInvalidMessage = 'Email inválido';
  static const String passwordRequiredMessage = 'Senha é obrigatória';
  static const String passwordMinLengthMessage = 'Senha deve ter pelo menos 6 caracteres';
  static const String nameRequiredMessage = 'Nome é obrigatório';
  static const String matriculaRequiredMessage = 'Matrícula é obrigatória';
  static const String matriculaInvalidMessage = 'Matrícula inválida';

  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String signupSuccessMessage = 'Conta criada com sucesso!';
  static const String topicChosenMessage = 'Tópico escolhido com sucesso!';
  static const String topicUnchosenMessage = 'Tópico desmarcado com sucesso!';
  static const String commentAddedMessage = 'Comentário adicionado!';
  static const String commentLabelText = 'Escreva um comentário...';
  static const String commentHintText = 'Digite sua mensagem';

  // --- ANIMAÇÕES ---
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // --- COLEÇÕES DO FIRESTORE ---
  static const String usersCollection = 'users';
  static const String topicsCollection = 'topics';
  static const String announcementsCollection = 'announcements';
  static const String commentsCollection = 'comments';

  // --- DECORAÇÃO DE INPUT ---
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppConstants.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppConstants.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppConstants.errorColor),
      ),
    );
  }
}