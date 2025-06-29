import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/gallery_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/gallery_model.dart';
import '../../utils/app_utils.dart';

class GalleryListView extends StatelessWidget {
  const GalleryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryController controller = Get.put(GalleryController());
    
    return SidebarLayout(
      title: AppStrings.gallery,
      child: Column(
        children: [
          // Header with search and filters
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.searchController,
                        label: '',
                        hintText: 'Search gallery images...',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    
                    SizedBox(width: 16.w),
                    
                    // Category Filter
                    Expanded(
                      flex: 2,
                      child: Obx(() => CustomDropdown<String>(
                        label: '',
                        value: controller.selectedCategoryFilter.value,
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                          ...controller.galleryCategories.map((category) => 
                            DropdownMenuItem(value: category.id, child: Text(category.title))
                          ).toList(),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setCategoryFilter(value);
                          }
                        },
                        prefixIcon: Icons.category,
                      )),
                    ),
                    
                    SizedBox(width: 16.w),
                    
                    // Add Category Button
                    CustomButton(
                      text: 'Add Category',
                      icon: Icons.add_box,
                      outlined: true,
                      onPressed: () => _showCategoryDialog(controller),
                    ),
                    
                    SizedBox(width: 16.w),
                    
                    // Add Gallery Button
                    CustomButton(
                      text: AppStrings.addGallery,
                      icon: Icons.add,
                      onPressed: () => _showGalleryDialog(controller),
                    ),
                  ],
                ),
                
                SizedBox(height: 16.h),
                
                // Categories List
                Obx(() => controller.galleryCategories.isNotEmpty
                    ? Container(
                        height: 40.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.galleryCategories.length,
                          itemBuilder: (context, index) {
                            final category = controller.galleryCategories[index];
                            return Container(
                              margin: EdgeInsets.only(right: 8.w),
                              child: Chip(
                                label: Text(category.title),
                                deleteIcon: Icon(Icons.close, size: 16.sp),
                                onDeleted: () => controller.deleteGalleryCategory(category),
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          
          // Gallery Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.galleries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredGalleries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No gallery images found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first gallery image to get started',
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
                onRefresh: () => controller.loadGalleries(refresh: true),
                child: GridView.builder(
                  padding: EdgeInsets.all(24.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.filteredGalleries.length,
                  itemBuilder: (context, index) {
                    final gallery = controller.filteredGalleries[index];
                    return _buildGalleryCard(gallery, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGalleryCard(GalleryModel gallery, GalleryController controller) {
    final category = controller.galleryCategories
        .firstWhereOrNull((cat) => cat.id == gallery.catId);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: gallery.img,
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
                  
                  // Category Badge
                  if (category != null)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  
                  // Action Buttons
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showImagePreview(gallery),
                          icon: Icon(
                            Icons.visibility,
                            color: AppColors.textWhite,
                            size: 16.sp,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.info.withValues(alpha: 0.8),
                            minimumSize: Size(32.w, 32.h),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        IconButton(
                          onPressed: () => _showGalleryDialog(controller, gallery: gallery),
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
                          onPressed: () => controller.deleteGallery(gallery),
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
          
          // Gallery Info
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Text(
              gallery.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
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
  
  void _showImagePreview(GalleryModel gallery) {
    Get.dialog(
      Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 800.w,
            maxHeight: 600.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        gallery.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Image
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: gallery.img,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
              
              if (gallery.description?.isNotEmpty == true)
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    gallery.description!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCategoryDialog(GalleryController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    Get.dialog(
      Dialog(
        child: Container(
          width: 400.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Gallery Category',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              CustomTextField(
                controller: titleController,
                label: 'Category Name',
                hintText: 'Enter category name',
              ),
              
              SizedBox(height: 16.h),
              
              CustomTextField(
                controller: descriptionController,
                label: 'Description (Optional)',
                hintText: 'Enter category description',
                maxLines: 3,
              ),
              
              SizedBox(height: 24.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isNotEmpty) {
                        await controller.createGalleryCategory(
                          titleController.text.trim(),
                          descriptionController.text.trim(),
                        );
                        Get.back();
                      }
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showGalleryDialog(GalleryController controller, {GalleryModel? gallery}) {
    final isEdit = gallery != null;
    
    if (isEdit) {
      controller.loadGalleryForEdit(gallery);
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
                isEdit ? 'Edit Gallery Image' : 'Add Gallery Image',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Gallery Form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.titleController,
                      label: 'Image Title',
                      hintText: 'Enter image title',
                      validator: (value) => controller.validateRequired(value, 'Image title'),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    CustomTextField(
                      controller: controller.descriptionController,
                      label: 'Description (Optional)',
                      hintText: 'Enter image description',
                      maxLines: 3,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    Obx(() => CustomDropdown<String>(
                      label: 'Category',
                      value: controller.selectedCategoryId.value.isEmpty 
                          ? null 
                          : controller.selectedCategoryId.value,
                      items: controller.galleryCategories
                          .map((category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.title),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedCategoryId.value = value;
                        }
                      },
                      validator: (value) => value == null ? 'Please select a category' : null,
                    )),
                    
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
                                    'Click to upload gallery image',
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
                            await controller.saveGallery();
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
