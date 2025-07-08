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
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color iconColor = Color(0xFF616161);
  static const Color borderColor = Color(0xFFBDBDBD);

  // --- PADDING ---
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 22.0;
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
  static const String passwordMinLengthMessage =
      'Senha deve ter pelo menos 6 caracteres';
  static const String nameRequiredMessage = 'Nome é obrigatório';
  static const String matriculaRequiredMessage = 'Matrícula é obrigatória';
  static const String matriculaInvalidMessage = 'Matrícula inválida';

  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String signupSuccessMessage = 'Conta criada com sucesso!';
  static const String topicChosenMessage = 'Tema escolhido com sucesso!';
  static const String topicUnchosenMessage = 'Tema desmarcado com sucesso!';
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

  // --- TEMA CENTRALIZADO ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Esquema de cores principal
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
      ),

      // Cores básicas
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,

      // Tipografia
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineLarge: heading1,
        headlineMedium: heading2,
        headlineSmall: heading3,
        titleLarge: heading2,
        titleMedium: heading3,
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: bodyText,
        bodyMedium: bodyText.copyWith(fontSize: 14),
        bodySmall: caption,
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        labelMedium: caption,
        labelSmall: caption.copyWith(fontSize: 12),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: heading2.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: paddingMedium,
            horizontal: paddingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            vertical: paddingMedium,
            horizontal: paddingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.only(
            left: paddingLarge/1.5,
            right: paddingLarge/1.5,
            top: paddingMedium/2,
            bottom: paddingMedium/2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.all(paddingMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(
            color: textSecondaryColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textSecondaryColor.withValues(alpha: 0.7)),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: paddingSmall,
          vertical: paddingSmall,
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Icons
      iconTheme: const IconThemeData(
        color: iconColor,
        size: 24,
      ),

      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: bodyText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        actionTextColor: primaryColor,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        iconColor: iconColor,
        textColor: textPrimaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
      ),

      // ExpansionTile
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: cardColor,
        collapsedBackgroundColor: cardColor,
        iconColor: primaryColor,
        collapsedIconColor: iconColor,
        textColor: textPrimaryColor,
        collapsedTextColor: textPrimaryColor,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return borderColor;
        }),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return borderColor;
        }),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: heading3,
        contentTextStyle: bodyText,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: caption,
        secondaryLabelStyle: caption.copyWith(color: Colors.white),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimaryColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        textStyle: caption.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
      ),
    );
  }

  // --- DECORAÇÃO DE INPUT (mantida para compatibilidade) ---
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
        borderSide: BorderSide(
          color: AppConstants.textSecondaryColor.withValues(alpha: 0.3),
        ),
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