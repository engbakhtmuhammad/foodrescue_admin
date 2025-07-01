import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/surprise_bag_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_time_picker.dart';
import '../../widgets/chip_text_field.dart';

class SurpriseBagFormView extends StatelessWidget {
  const SurpriseBagFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final SurpriseBagController controller = Get.put(SurpriseBagController());
    
    return SidebarLayout(
      title: controller.currentSurpriseBag.value != null 
          ? 'Edit Surprise Bag' 
          : 'Add New Surprise Bag',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: controller.formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Main Form
              Expanded(
                flex: 2,
                child: _buildMainForm(controller),
              ),
              
              SizedBox(width: 24.w),
              
              // Right Column - Image and Additional Info
              Expanded(
                flex: 1,
                child: _buildSideForm(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainForm(SurpriseBagController controller) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: 24.h),

          // Title and Category Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.titleController,
                  label: 'Surprise Bag Title',
                  hintText: 'e.g., Mixed Bakery Items',
                  validator: (value) => controller.validateRequired(value, 'Title'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(() => CustomDropdown<String>(
                  label: 'Category',
                  value: controller.selectedCategoryId.value.isEmpty
                      ? null
                      : controller.selectedCategoryId.value,
                  items: controller.availableCuisines.map((cuisine) =>
                    DropdownMenuItem<String>(
                      value: cuisine.id,
                      child: Text(cuisine.title),
                    ),
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedCategoryId.value = value;
                    }
                  },
                  validator: (value) => controller.validateRequired(value, 'Category'),
                )),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Description
          CustomTextField(
            controller: controller.descriptionController,
            label: 'Description',
            hintText: 'Describe what customers can expect in this surprise bag',
            maxLines: 3,
            validator: (value) => controller.validateRequired(value, 'Description'),
          ),
          
          SizedBox(height: 24.h),
          
          // Pricing Section
          Text(
            'Pricing & Availability',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Price Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.originalPriceController,
                  label: 'Original Price',
                  hintText: 'Enter original price',
                  keyboardType: TextInputType.number,
                  validator: (value) => controller.validatePositiveNumber(value, 'Original price'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomTextField(
                  controller: controller.discountedPriceController,
                  label: 'Discounted Price',
                  hintText: 'Enter discounted price',
                  keyboardType: TextInputType.number,
                  validator: (value) => controller.validatePositiveNumber(value, 'Discounted price'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Items Row
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.totalItemsController,
                  label: 'Total Items Available',
                  hintText: 'Total number of bags',
                  keyboardType: TextInputType.number,
                  validator: (value) => controller.validatePositiveNumber(value, 'Total items'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomTextField(
                  controller: controller.itemsLeftController,
                  label: 'Items Left',
                  hintText: 'Current available bags',
                  keyboardType: TextInputType.number,
                  validator: (value) => controller.validateNumber(value, 'Items left'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Pickup Information Section
          Text(
            'Pickup Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Pickup Type
          Obx(() => CustomDropdown<String>(
            label: 'Pickup Availability',
            value: controller.selectedPickupType.value,
            items: const [
              DropdownMenuItem(value: 'today', child: Text('Today Only')),
              DropdownMenuItem(value: 'tomorrow', child: Text('Tomorrow Only')),
              DropdownMenuItem(value: 'both', child: Text('Today & Tomorrow')),
            ],
            onChanged: (value) {
              if (value != null) {
                controller.selectedPickupType.value = value;
              }
            },
          )),
          
          SizedBox(height: 16.h),
          
          // Today Pickup Times
          Obx(() {
            if (controller.selectedPickupType.value == 'today' || 
                controller.selectedPickupType.value == 'both') {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimePicker(
                          controller: controller.todayPickupStartController,
                          label: 'Today Pickup Start',
                          hintText: 'Select start time',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTimePicker(
                          controller: controller.todayPickupEndController,
                          label: 'Today Pickup End',
                          hintText: 'Select end time',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Tomorrow Pickup Times
          Obx(() {
            if (controller.selectedPickupType.value == 'tomorrow' || 
                controller.selectedPickupType.value == 'both') {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTimePicker(
                          controller: controller.tomorrowPickupStartController,
                          label: 'Tomorrow Pickup Start',
                          hintText: 'Select start time',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTimePicker(
                          controller: controller.tomorrowPickupEndController,
                          label: 'Tomorrow Pickup End',
                          hintText: 'Select end time',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Pickup Address (Auto-filled from restaurant)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Address',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() {
                  final selectedRestaurant = controller.restaurants.firstWhereOrNull(
                    (r) => r.id == controller.selectedRestaurantId.value,
                  );
                  return Text(
                    selectedRestaurant?.fullAddress ?? 'Select a restaurant first',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: selectedRestaurant != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  );
                }),
                SizedBox(height: 4.h),
                Text(
                  'Address is automatically taken from the selected restaurant',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Pickup Instructions
          CustomTextField(
            controller: controller.pickupInstructionsController,
            label: 'Pickup Instructions',
            hintText: 'Special instructions for pickup (optional)',
            maxLines: 2,
          ),
          
          SizedBox(height: 32.h),
          
          // Save Button
          Obx(() => CustomButton(
            text: controller.currentSurpriseBag.value != null 
                ? 'Update Surprise Bag' 
                : 'Create Surprise Bag',
            onPressed: controller.isLoading.value ? null : controller.saveSurpriseBag,
            isLoading: controller.isLoading.value,
          )),
        ],
      ),
    );
  }

  Widget _buildSideForm(SurpriseBagController controller) {
    return Column(
      children: [
        // Image Upload Section
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Surprise Bag Image',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16.h),

              // Image Preview
              Obx(() => Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: controller.uploadedImageUrl.value.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48.sp,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No image selected',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: controller.uploadedImageUrl.value,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
              )),

              SizedBox(height: 16.h),

              // Upload Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Select Image',
                  onPressed: controller.pickImage,
                  outlined: true,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Content Information Section
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 16.h),

              // Dietary Information Checkboxes
              Text(
                'Dietary Information',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              Obx(() => Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Vegetarian',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: controller.selectedIsVegetarian.value,
                    onChanged: (value) {
                      controller.selectedIsVegetarian.value = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Vegan',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: controller.selectedIsVegan.value,
                    onChanged: (value) {
                      controller.selectedIsVegan.value = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Gluten Free',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    value: controller.selectedIsGlutenFree.value,
                    onChanged: (value) {
                      controller.selectedIsGlutenFree.value = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              )),

              SizedBox(height: 16.h),

              // Additional Dietary Info
              CustomTextField(
                controller: controller.dietaryInfoController,
                label: 'Additional Dietary Info',
                hintText: 'Any other dietary information',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
