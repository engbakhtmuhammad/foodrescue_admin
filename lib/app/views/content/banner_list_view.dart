import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/banner_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/banner_model.dart';
import '../../utils/app_utils.dart';

class BannerListView extends StatelessWidget {
  const BannerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.put(BannerController());
    
    return SidebarLayout(
      title: AppStrings.banners,
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
                    hintText: 'Search banners...',
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
                
                // Add Banner Button
                CustomButton(
                  text: AppStrings.addBanner,
                  icon: Icons.add,
                  onPressed: () => _showBannerDialog(controller),
                ),
              ],
            ),
          ),
          
          // Banners Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.banners.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredBanners.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No banners found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first banner to get started',
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
                onRefresh: () => controller.loadBanners(refresh: true),
                child: GridView.builder(
                  padding: EdgeInsets.all(24.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 16 / 9,
                  ),
                  itemCount: controller.filteredBanners.length,
                  itemBuilder: (context, index) {
                    final banner = controller.filteredBanners[index];
                    return _buildBannerCard(banner, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBannerCard(BannerModel banner, BannerController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: banner.img,
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
                          Icons.error,
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
                    child: _buildStatusChip(banner.status),
                  ),
                  
                  // Action Buttons
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showBannerDialog(controller, banner: banner),
                          icon: Icon(
                            Icons.edit,
                            color: AppColors.textWhite,
                            size: 20.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: () => controller.toggleBannerStatus(banner),
                          icon: Icon(
                            banner.status == 'active' ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textWhite,
                            size: 20.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: (banner.status == 'active' ? AppColors.warning : AppColors.success).withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: () => controller.deleteBanner(banner),
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.textWhite,
                            size: 20.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Banner Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (banner.link != null && banner.link!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    banner.link!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                SizedBox(height: 8.h),
                
                Row(
                  children: [
                    Icon(
                      Icons.sort,
                      size: 14.sp,
                      color: AppColors.textHint,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Order: ${banner.sortOrder}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        AppUtils.capitalizeFirst(status),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
  
  void _showBannerDialog(BannerController controller, {BannerModel? banner}) {
    final isEdit = banner != null;
    
    if (isEdit) {
      controller.loadBannerForEdit(banner);
    } else {
      controller.clearForm();
    }
    
    Get.dialog(
      Dialog(
        child: Container(
          width: 600.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Banner' : 'Add New Banner',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Banner Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.titleController,
                      label: 'Banner Title',
                      hintText: 'Enter banner title',
                      validator: (value) => controller.validateRequired(value, 'Banner title'),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    CustomTextField(
                      controller: controller.linkController,
                      label: 'Link (Optional)',
                      hintText: 'Enter banner link',
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.sortOrderController,
                            label: 'Sort Order',
                            hintText: 'Enter sort order',
                            keyboardType: TextInputType.number,
                            validator: (value) => controller.validateNumber(value, 'Sort order'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Obx(() => CustomDropdown<String>(
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
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Image Upload
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
                                    'Click to upload banner image',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 14.sp,
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
                            await controller.saveBanner();
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
