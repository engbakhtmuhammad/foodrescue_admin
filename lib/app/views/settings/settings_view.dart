import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    
    return SidebarLayout(
      title: AppStrings.settings,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSectionCard(
              title: 'Application Settings',
              icon: Icons.settings,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.appNameController,
                        label: 'Application Name',
                        hintText: 'Enter application name',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.appVersionController,
                        label: 'Application Version',
                        hintText: 'Enter version',
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                CustomTextField(
                  controller: controller.appDescriptionController,
                  label: 'Application Description',
                  hintText: 'Enter application description',
                  maxLines: 3,
                ),
                
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.supportEmailController,
                        label: 'Support Email',
                        hintText: 'Enter support email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.supportPhoneController,
                        label: 'Support Phone',
                        hintText: 'Enter support phone',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Payment Settings Section
            _buildSectionCard(
              title: 'Payment Settings',
              icon: Icons.payment,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.currencyController,
                        label: 'Default Currency',
                        hintText: 'e.g., USD, EUR, INR',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.currencySymbolController,
                        label: 'Currency Symbol',
                        hintText: "e.g., \$, €, ₹",
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.taxRateController,
                        label: 'Tax Rate (%)',
                        hintText: 'Enter tax rate',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.deliveryChargeController,
                        label: 'Delivery Charge',
                        hintText: 'Enter delivery charge',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.minOrderAmountController,
                        label: 'Minimum Order Amount',
                        hintText: 'Enter minimum order amount',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.freeDeliveryAboveController,
                        label: 'Free Delivery Above',
                        hintText: 'Enter amount for free delivery',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Notification Settings Section
            _buildSectionCard(
              title: 'Notification Settings',
              icon: Icons.notifications,
              children: [
                Obx(() => SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Send notifications via email'),
                  value: controller.emailNotificationsEnabled.value,
                  onChanged: (value) => controller.emailNotificationsEnabled.value = value,
                )),
                
                Obx(() => SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Send push notifications to mobile apps'),
                  value: controller.pushNotificationsEnabled.value,
                  onChanged: (value) => controller.pushNotificationsEnabled.value = value,
                )),
                
                Obx(() => SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Send notifications via SMS'),
                  value: controller.smsNotificationsEnabled.value,
                  onChanged: (value) => controller.smsNotificationsEnabled.value = value,
                )),
                
                SizedBox(height: 16.h),
                
                CustomTextField(
                  controller: controller.notificationEmailController,
                  label: 'Notification Email',
                  hintText: 'Enter email for notifications',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Business Settings Section
            _buildSectionCard(
              title: 'Business Settings',
              icon: Icons.business,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.businessNameController,
                        label: 'Business Name',
                        hintText: 'Enter business name',
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.businessEmailController,
                        label: 'Business Email',
                        hintText: 'Enter business email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                CustomTextField(
                  controller: controller.businessAddressController,
                  label: 'Business Address',
                  hintText: 'Enter business address',
                  maxLines: 3,
                ),
                
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.businessPhoneController,
                        label: 'Business Phone',
                        hintText: 'Enter business phone',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.businessWebsiteController,
                        label: 'Business Website',
                        hintText: 'Enter website URL',
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Order Settings Section
            _buildSectionCard(
              title: 'Order Settings',
              icon: Icons.shopping_cart,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.orderTimeoutController,
                        label: 'Order Timeout (minutes)',
                        hintText: 'Enter order timeout',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.maxOrdersPerDayController,
                        label: 'Max Orders Per Day',
                        hintText: 'Enter max orders',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                Obx(() => SwitchListTile(
                  title: const Text('Auto Accept Orders'),
                  subtitle: const Text('Automatically accept new orders'),
                  value: controller.autoAcceptOrders.value,
                  onChanged: (value) => controller.autoAcceptOrders.value = value,
                )),
                
                Obx(() => SwitchListTile(
                  title: const Text('Allow Order Cancellation'),
                  subtitle: const Text('Allow customers to cancel orders'),
                  value: controller.allowOrderCancellation.value,
                  onChanged: (value) => controller.allowOrderCancellation.value = value,
                )),
              ],
            ),
            
            SizedBox(height: 32.h),
            
            // Save Button
            Row(
              children: [
                Expanded(
                  child: Obx(() => CustomButton(
                    text: 'Save Settings',
                    onPressed: controller.isLoading.value ? null : controller.saveSettings,
                    isLoading: controller.isLoading.value,
                    width: double.infinity,
                  )),
                ),
                SizedBox(width: 16.w),
                CustomButton(
                  text: 'Reset to Default',
                  outlined: true,
                  onPressed: controller.resetToDefault,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            ...children,
          ],
        ),
      ),
    );
  }
}
