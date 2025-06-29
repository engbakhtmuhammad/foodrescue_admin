import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/cuisine_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/cuisine_model.dart';
import '../../utils/app_utils.dart';

class CuisineListView extends StatelessWidget {
  const CuisineListView({super.key});

  @override
  Widget build(BuildContext context) {
    final CuisineController controller = Get.put(CuisineController());
    
    return SidebarLayout(
      title: AppStrings.cuisines,
      child: Column(
        children: [
          // Header with search and filters
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: controller.searchController,
                    label: '',
                    hintText: 'Search cuisines...',
                    prefixIcon: Icons.search,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Status Filter
                Expanded(
                  flex: 2,
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedStatusFilter.value,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStatusFilter(value);
                      }
                    },
                    prefixIcon: Icons.filter_list,
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Cuisine Button
                CustomButton(
                  text: AppStrings.addCuisine,
                  icon: Icons.add,
                  onPressed: () => _showCuisineDialog(controller),
                ),
              ],
            ),
          ),
          
          // Cuisines Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.cuisines.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredCuisines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No cuisines found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first cuisine to get started',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () => controller.loadCuisines(refresh: true),
                child: GridView.builder(
                  padding: EdgeInsets.all(24.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.filteredCuisines.length,
                  itemBuilder: (context, index) {
                    final cuisine = controller.filteredCuisines[index];
                    return _buildCuisineCard(cuisine, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCuisineCard(CuisineModel cuisine, CuisineController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cuisine Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: cuisine.img,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.background,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.background,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.error,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status Badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _buildStatusChip(cuisine.status),
                  ),
                  
                  // Action Buttons
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showCuisineDialog(controller, cuisine: cuisine),
                          icon: Icon(
                            Icons.edit,
                            color: AppColors.textWhite,
                            size: 16.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                            minimumSize: Size(32.w, 32.h),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        IconButton(
                          onPressed: () => controller.toggleCuisineStatus(cuisine),
                          icon: Icon(
                            cuisine.status == 'active' ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textWhite,
                            size: 16.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: (cuisine.status == 'active' ? AppColors.warning : AppColors.success).withValues(alpha: 0.8),
                            minimumSize: Size(32.w, 32.h),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        IconButton(
                          onPressed: () => controller.deleteCuisine(cuisine),
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.textWhite,
                            size: 16.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha: 0.8),
                            minimumSize: Size(32.w, 32.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Cuisine Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(
              cuisine.title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        AppUtils.capitalizeFirst(status),
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
  
  void _showCuisineDialog(CuisineController controller, {CuisineModel? cuisine}) {
    final isEdit = cuisine != null;
    
    if (isEdit) {
      controller.loadCuisineForEdit(cuisine);
    } else {
      controller.clearForm();
    }
    
    Get.dialog(
      Dialog(
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Cuisine' : 'Add New Cuisine',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Cuisine Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.titleController,
                      label: 'Cuisine Name',
                      hintText: 'Enter cuisine name',
                      validator: (value) => controller.validateRequired(value, 'Cuisine name'),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    Obx(() => CustomDropdown<String>(
                      label: 'Status',
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
                    
                    // Image Upload
                    Obx(() => Container(
                      width: double.infinity,
                      height: 150.h,
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
                                    size: 32.sp,
                                    color: AppColors.textHint,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Click to upload cuisine image',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    )),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 16.w),
                  Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () async {
                            await controller.saveCuisine();
                            Get.back();
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Update' : 'Create'),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
