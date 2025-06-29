import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFFEB3B),
    Color(0xFF795548),
  ];
  
  // Restaurant Status Colors
  static const Color activeStatus = Color(0xFF4CAF50);
  static const Color inactiveStatus = Color(0xFFF44336);
  static const Color pendingStatus = Color(0xFFFF9800);
  
  // Order Status Colors
  static const Color orderPending = Color(0xFFFF9800);
  static const Color orderConfirmed = Color(0xFF2196F3);
  static const Color orderCompleted = Color(0xFF4CAF50);
  static const Color orderCancelled = Color(0xFFF44336);
  
  // Payment Status Colors
  static const Color paymentPending = Color(0xFFFF9800);
  static const Color paymentCompleted = Color(0xFF4CAF50);
  static const Color paymentFailed = Color(0xFFF44336);
  
  // Sidebar Colors
  static const Color sidebarBackground = Color(0xFF263238);
  static const Color sidebarSelected = Color(0xFF37474F);
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarIcon = Color(0xFFB0BEC5);
  
  // Dashboard Card Colors
  static const Color dashboardCard1 = Color(0xFF2196F3);
  static const Color dashboardCard2 = Color(0xFF4CAF50);
  static const Color dashboardCard3 = Color(0xFFFF9800);
  static const Color dashboardCard4 = Color(0xFFF44336);
  static const Color dashboardCard5 = Color(0xFF9C27B0);
  static const Color dashboardCard6 = Color(0xFF00BCD4);
}
