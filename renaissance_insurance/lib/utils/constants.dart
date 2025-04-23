import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// App Colors
class AppColors {
  static const primary = Color(0xFF1A237E); // Deep Indigo
  static const secondary = Color(0xFF00227B); // Dark Blue
  static const accent = Color(0xFFFF6D00); // Vibrant Orange
  static const background = Color(0xFFF5F7FA); // Light Gray
  static const cardBackground = Colors.white;
  static const error = Color(0xFFD32F2F); // Red
  static const success = Color(0xFF388E3C); // Green
  static const textPrimary = Color(0xFF212121); // Almost Black
  static const textSecondary = Color(0xFF757575); // Gray
  static const disabled = Color(0xFFBDBDBD); // Light Gray
  
  // Task Status Colors
  static const todo = Color(0xFFEF5350); // Red
  static const inProgress = Color(0xFFFFA726); // Orange
  static const done = Color(0xFF66BB6A); // Green
}

// Text Styles
class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get heading2 => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get heading3 => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get body => GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.roboto(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static TextStyle get button => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}

// App Theme
class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.cardBackground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.heading2.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.disabled),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.disabled),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTextStyles.bodySmall,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
    ),
  );
}

// String Constants
class AppStrings {
  static const appName = 'Renaissance Insurance';
  static const loginTitle = 'Welcome Back';
  static const loginSubtitle = 'Sign in to continue to your account';
  static const email = 'Email';
  static const password = 'Password';
  static const login = 'Login';
  static const logout = 'Logout';
  static const loginDemo = 'demo@renaissance.com / password123';
  
  // Task Board
  static const taskBoard = 'Task Board';
  static const todo = 'To Do';
  static const inProgress = 'In Progress';
  static const done = 'Done';
  static const addTask = 'Add Task';
  static const editTask = 'Edit Task';
  static const deleteTask = 'Delete Task';
  static const taskTitle = 'Title';
  static const taskDescription = 'Description';
  static const taskStatus = 'Status';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const delete = 'Delete';
  
  // Error Messages
  static const requiredField = 'This field is required';
  static const invalidEmail = 'Please enter a valid email address';
  static const loginFailed = 'Invalid email or password';
}

// Spacing Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius Constants
class AppBorderRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double extraLarge = 24.0;
} 