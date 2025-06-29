import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/restaurant_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_time_picker.dart';
import '../../widgets/multi_select_chips.dart';
import '../../widgets/chip_text_field.dart';

class RestaurantFormView extends StatelessWidget {
  final bool isEdit;
  
  const RestaurantFormView({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context) {
    final RestaurantController controller = Get.find<RestaurantController>();
    
    return SidebarLayout(
      title: isEdit ? AppStrings.editRestaurant : AppStrings.addRestaurant,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, size: 24.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isEdit ? 'Edit Restaurant Details' : 'Add New Restaurant',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Form Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    flex: 2,
                    child: _buildLeftColumn(controller),
                  ),
                  
                  SizedBox(width: 24.w),
                  
                  // Right Column
                  Expanded(
                    flex: 1,
                    child: _buildRightColumn(controller),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Action Buttons
              Row(
                children: [
                  CustomButton(
                    text: 'Cancel',
                    outlined: true,
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 16.w),
                  Obx(() => CustomButton(
                    text: isEdit ? 'Update Restaurant' : 'Create Restaurant',
                    onPressed: controller.isLoading.value ? null : controller.saveRestaurant,
                    isLoading: controller.isLoading.value,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeftColumn(RestaurantController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.w),
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
            
            // Restaurant Name
            CustomTextField(
              controller: controller.titleController,
              label: AppStrings.restaurantName,
              hintText: 'Enter restaurant name',
              validator: (value) => controller.validateRequired(value, 'Restaurant name'),
            ),
            
            SizedBox(height: 16.h),
            
            // Short Description
            CustomTextField(
              controller: controller.shortDescriptionController,
              label: AppStrings.shortDescription,
              hintText: 'Enter short description',
              maxLines: 3,
              validator: (value) => controller.validateRequired(value, 'Short description'),
            ),
            
            SizedBox(height: 16.h),
            
            // Email and Password Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.emailController,
                    label: AppStrings.email,
                    hintText: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.passwordController,
                    label: AppStrings.password,
                    hintText: 'Enter password',
                    obscureText: true,
                    validator: (value) => controller.validateRequired(value, 'Password'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Mobile and Certificate Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.mobileController,
                    label: AppStrings.mobileNumber,
                    hintText: 'Enter mobile number',
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhone,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.certificateCodeController,
                    label: AppStrings.certificateCode,
                    hintText: 'Enter certificate/license code',
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Rating and Price Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.ratingController,
                    label: AppStrings.rating,
                    hintText: 'Enter rating (0-5)',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateNumber(value, 'Rating'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.approxPriceController,
                    label: AppStrings.approxPrice,
                    hintText: 'Enter approximate price for two',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateNumber(value, 'Approximate price'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Time Row
            Row(
              children: [
                Expanded(
                  child: CustomTimePicker(
                    controller: controller.openTimeController,
                    label: AppStrings.openTime,
                    hintText: 'Select opening time',
                    validator: (value) => controller.validateRequired(value, 'Open time'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTimePicker(
                    controller: controller.closeTimeController,
                    label: AppStrings.closeTime,
                    hintText: 'Select closing time',
                    validator: (value) => controller.validateRequired(value, 'Close time'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Location Section
            Text(
              'Location Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Full Address
            CustomTextField(
              controller: controller.fullAddressController,
              label: AppStrings.fullAddress,
              hintText: 'Enter full address',
              maxLines: 2,
              validator: (value) => controller.validateRequired(value, 'Full address'),
            ),
            
            SizedBox(height: 16.h),
            
            // Pincode and Area Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.pincodeController,
                    label: AppStrings.pincode,
                    hintText: 'Enter pincode',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateRequired(value, 'Pincode'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.areaController,
                    label: AppStrings.area,
                    hintText: 'Enter area/locality',
                    validator: (value) => controller.validateRequired(value, 'Area'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Coordinates Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.latitudeController,
                    label: AppStrings.latitude,
                    hintText: 'Enter latitude',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateNumber(value, 'Latitude'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.longitudeController,
                    label: AppStrings.longitude,
                    hintText: 'Enter longitude',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateNumber(value, 'Longitude'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.showRadiusController,
                    label: AppStrings.showRadius,
                    hintText: 'Enter radius in km',
                    keyboardType: TextInputType.number,
                    validator: (value) => controller.validateNumber(value, 'Show radius'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Cuisine Selection Section
            Text(
              'Cuisine Selection',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 16.h),

            Obx(() => MultiSelectDropdown(
              label: 'Cuisines',
              hintText: 'Select cuisines',
              items: controller.availableCuisines,
              selectedIds: controller.selectedCuisines,
              getItemId: (cuisine) => cuisine.id,
              getItemTitle: (cuisine) => cuisine.title,
              onToggle: controller.toggleCuisineSelection,
              isLoading: controller.isLoading.value,
            )),

            SizedBox(height: 24.h),

            // Facility Selection Section
            Text(
              'Facility Selection',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 16.h),

            Obx(() => MultiSelectDropdown(
              label: 'Facilities',
              hintText: 'Select facilities',
              items: controller.availableFacilities,
              selectedIds: controller.selectedFacilities,
              getItemId: (facility) => facility.id,
              getItemTitle: (facility) => facility.title,
              onToggle: controller.toggleFacilitySelection,
              isLoading: controller.isLoading.value,
            )),

            SizedBox(height: 24.h),

            // Popular Dishes Section
            Text(
              'Popular Dishes',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 16.h),

            ChipTextField(
              controller: controller.popularDishesController,
              label: 'Popular Dishes',
              hintText: 'Type dish name and press comma to add',
              separator: ',',
            ),

            SizedBox(height: 24.h),

            // Offers Section
            Text(
              'Special Offers',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 16.h),

            // Monday to Thursday Offer
            CustomTextField(
              controller: controller.mondayThursdayOfferController,
              label: 'Monday to Thursday Offer',
              hintText: 'Enter offer title (e.g., 20% Off)',
            ),

            SizedBox(height: 16.h),

            CustomTextField(
              controller: controller.mondayThursdayOfferDescController,
              label: 'Monday to Thursday Offer Description',
              hintText: 'Enter detailed offer description',
              maxLines: 2,
            ),

            SizedBox(height: 16.h),

            // Friday to Sunday Offer
            CustomTextField(
              controller: controller.fridaySundayOfferController,
              label: 'Friday to Sunday Offer',
              hintText: 'Enter offer title (e.g., Buy 1 Get 1 Free)',
            ),

            SizedBox(height: 16.h),

            CustomTextField(
              controller: controller.fridaySundayOfferDescController,
              label: 'Friday to Sunday Offer Description',
              hintText: 'Enter detailed offer description',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRightColumn(RestaurantController controller) {
    return Column(
      children: [
        // Restaurant Image
        Card(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.restaurantImage,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                Obx(() => Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: controller.uploadedImageUrl.value.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: controller.uploadedImageUrl.value,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: controller.pickImage,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 48.sp,
                                color: AppColors.textHint,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Click to upload image',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                )),
                
                if (controller.uploadedImageUrl.value.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: 'Change Image',
                    outlined: true,
                    onPressed: controller.pickImage,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Status and Settings
        Card(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Status Dropdown
                Obx(() => CustomDropdown<String>(
                  label: AppStrings.restaurantStatus,
                  value: controller.selectedStatus.value,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedStatus.value = value;
                    }
                  },
                )),
                
                SizedBox(height: 16.h),
                
                // Table Booking Show
                Obx(() => CustomDropdown<bool>(
                  label: AppStrings.tableBookingShow,
                  value: controller.selectedTableBookingShow.value,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Show')),
                    DropdownMenuItem(value: false, child: Text('Hide')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedTableBookingShow.value = value;
                    }
                  },
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
