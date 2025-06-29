import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class AppUtils {
  // Date and Time Formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatCurrency(double amount, {String currency = '\$'}) {
    return '$currency${amount.toStringAsFixed(2)}';
  }
  
  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }
  
  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(url);
  }
  
  // Snackbar Messages
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.textWhite,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: AppColors.textWhite),
    );
  }
  
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textWhite,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: AppColors.textWhite),
    );
  }
  
  static void showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.textWhite,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.warning, color: AppColors.textWhite),
    );
  }
  
  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.textWhite,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: AppColors.textWhite),
    );
  }
  
  // Loading Dialog
  static void showLoadingDialog({String message = 'Loading...'}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
  
  // Confirmation Dialog
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // Image Size Validation
  static bool isValidImageSize(int sizeInBytes, {int maxSizeMB = 5}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return sizeInBytes <= maxSizeBytes;
  }
  
  // File Extension Validation
  static bool isValidImageExtension(String fileName) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }
  
  // Generate Random ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Capitalize First Letter
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'inactive':
      case 'cancelled':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
  
  // Get Status Icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'completed':
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'inactive':
      case 'cancelled':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
  
  // Format File Size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // Debounce Function
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
}
