import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Form(
                    key: authController.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            color: AppColors.textWhite,
                            size: 40.sp,
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Title
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        // Subtitle
                        Text(
                          AppStrings.signInToAccount,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        Text(
                          AppStrings.enterEmailPassword,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Email Field
                        CustomTextField(
                          controller: authController.emailController,
                          label: AppStrings.email,
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: authController.validateEmail,
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Password Field
                        Obx(() => CustomTextField(
                          controller: authController.passwordController,
                          label: AppStrings.password,
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: authController.obscurePassword.value,
                          suffixIcon: IconButton(
                            onPressed: authController.togglePasswordVisibility,
                            icon: Icon(
                              authController.obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          validator: authController.validatePassword,
                        )),
                        
                        SizedBox(height: 16.h),
                        
                        // Role Selection
                        Obx(() => CustomDropdown<String>(
                          label: AppStrings.selectRole,
                          value: authController.selectedRole.value,
                          items: authController.availableRoles
                              .map((role) => DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(authController.getRoleDisplayName(role)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              authController.setSelectedRole(value);
                            }
                          },
                          prefixIcon: Icons.person_outline,
                        )),
                        
                        SizedBox(height: 24.h),
                        
                        // Sign In Button
                        Obx(() => CustomButton(
                          text: AppStrings.signIn,
                          onPressed: authController.isLoading.value
                              ? null
                              : authController.signIn,
                          isLoading: authController.isLoading.value,
                          width: double.infinity,
                        )),
                        
                        SizedBox(height: 16.h),
                        
                        // Forgot Password
                        TextButton(
                          onPressed: () => _showForgotPasswordDialog(authController),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showForgotPasswordDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: authController.emailController,
              label: 'Email Address',
              hintText: 'Enter your email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authController.resetPassword();
              Get.back();
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
