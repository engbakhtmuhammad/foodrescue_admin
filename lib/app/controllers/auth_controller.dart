import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  // Observable variables
  final isLoading = false.obs;
  final selectedRole = AppConstants.adminRole.obs;
  final obscurePassword = true.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onClose() {
    // Safely dispose controllers
    try {
      emailController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    try {
      passwordController.dispose();
    } catch (e) {
      // Controller already disposed
    }
    super.onClose();
  }
  
  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  // Set selected role
  void setSelectedRole(String role) {
    selectedRole.value = role;
  }
  
  // Sign in
  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    isLoading.value = true;
    
    final success = await _authService.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole.value,
    );
    
    if (success) {
      // Clear form
      emailController.clear();
      passwordController.clear();
      
      // Navigate to dashboard
      Get.offAllNamed('/dashboard');
    }
    
    isLoading.value = false;
  }
  
  // Sign out
  Future<void> signOut() async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );
    
    if (confirmed) {
      await _authService.signOut();
      Get.offAllNamed('/login');
    }
  }
  
  // Reset password
  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      AppUtils.showErrorSnackbar('Please enter your email address');
      return;
    }
    
    if (!AppUtils.isValidEmail(emailController.text.trim())) {
      AppUtils.showErrorSnackbar('Please enter a valid email address');
      return;
    }
    
    await _authService.resetPassword(emailController.text.trim());
  }
  
  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!AppUtils.isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.trim().length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    
    return null;
  }
  
  // Get available roles
  List<String> get availableRoles => [
    AppConstants.adminRole,
    AppConstants.restaurantOwnerRole,
  ];
  
  // Get role display name
  String getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.adminRole:
        return 'Admin';
      case AppConstants.restaurantOwnerRole:
        return 'Restaurant Owner';
      default:
        return role;
    }
  }
}
