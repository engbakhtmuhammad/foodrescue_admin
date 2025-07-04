import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - TGTG Teal Theme
  static const Color primary = Color(0xFF00695C); // Teal 800
  static const Color primaryDark = Color(0xFF004D40); // Teal 900
  static const Color primaryLight = Color(0xFF4DB6AC); // Teal 300

  // Secondary Colors - Complementary Orange
  static const Color secondary = Color(0xFFFF7043); // Deep Orange 400
  static const Color secondaryDark = Color(0xFFE64A19); // Deep Orange 700
  static const Color secondaryLight = Color(0xFFFFAB91); // Deep Orange 200
  
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
  
  // Chart Colors - Teal Theme
  static const List<Color> chartColors = [
    Color(0xFF00695C), // Teal 800
    Color(0xFF4CAF50), // Green 400
    Color(0xFFFF7043), // Deep Orange 400
    Color(0xFFF44336), // Red 400
    Color(0xFF26A69A), // Teal 400
    Color(0xFF80CBC4), // Teal 200
    Color(0xFFFFAB91), // Deep Orange 200
    Color(0xFF4DB6AC), // Teal 300
  ];
  
  // Restaurant Status Colors
  static const Color activeStatus = Color(0xFF4CAF50);
  static const Color inactiveStatus = Color(0xFFF44336);
  static const Color pendingStatus = Color(0xFFFF9800);
  
  // Order Status Colors - Teal Theme
  static const Color orderPending = Color(0xFFFF7043); // Deep Orange 400
  static const Color orderConfirmed = Color(0xFF00695C); // Teal 800
  static const Color orderCompleted = Color(0xFF4CAF50); // Green 400
  static const Color orderCancelled = Color(0xFFF44336); // Red 400
  
  // Payment Status Colors
  static const Color paymentPending = Color(0xFFFF9800);
  static const Color paymentCompleted = Color(0xFF4CAF50);
  static const Color paymentFailed = Color(0xFFF44336);
  
  // Sidebar Colors - Teal Theme
  static const Color sidebarBackground = Color(0xFF004D40); // Teal 900
  static const Color sidebarSelected = Color(0xFF00695C); // Teal 800
  static const Color sidebarText = Color(0xFFFFFFFF);
  static const Color sidebarIcon = Color(0xFF4DB6AC); // Teal 300
  
  // Dashboard Card Colors - Teal Theme
  static const Color dashboardCard1 = Color(0xFF00695C); // Teal 800
  static const Color dashboardCard2 = Color(0xFF4CAF50); // Green 400
  static const Color dashboardCard3 = Color(0xFFFF7043); // Deep Orange 400
  static const Color dashboardCard4 = Color(0xFFF44336); // Red 400
  static const Color dashboardCard5 = Color(0xFF26A69A); // Teal 400
  static const Color dashboardCard6 = Color(0xFF80CBC4); // Teal 200
}
