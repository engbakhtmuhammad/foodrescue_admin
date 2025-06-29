import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/menu_controller.dart' as menu_ctrl;
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/menu_model.dart';
import '../../utils/app_utils.dart';

class MenuListView extends StatelessWidget {
  const MenuListView({super.key});

  @override
  Widget build(BuildContext context) {
    final menu_ctrl.MenuController controller = Get.put(menu_ctrl.MenuController());
    
    return SidebarLayout(
      title: AppStrings.menus,
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
                    hintText: 'Search menu items...',
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
                      ...controller.categories.map((category) =>
                        DropdownMenuItem(value: category, child: Text(category))
                      ),
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
                
                // Availability Filter
                Expanded(
                  flex: 2,
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedAvailabilityFilter.value,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Items')),
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setAvailabilityFilter(value);
                      }
                    },
                    prefixIcon: Icons.filter_list,
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Menu Button
                CustomButton(
                  text: AppStrings.addMenu,
                  icon: Icons.add,
                  onPressed: () => _showMenuDialog(controller),
                ),
              ],
            ),
          ),
          
          // Menu Items List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.menus.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredMenus.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No menu items found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first menu item to get started',
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
                onRefresh: () => controller.loadMenus(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredMenus.length,
                  itemBuilder: (context, index) {
                    final menu = controller.filteredMenus[index];
                    return _buildMenuCard(menu, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuCard(MenuModel menu, menu_ctrl.MenuController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Menu Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: menu.img,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80.w,
                  height: 80.w,
                  color: AppColors.background,
                  child: Icon(
                    Icons.restaurant,
                    color: AppColors.textHint,
                    size: 32.sp,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80.w,
                  height: 80.w,
                  color: AppColors.background,
                  child: Icon(
                    Icons.error,
                    color: AppColors.error,
                    size: 32.sp,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Menu Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          menu.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildVegChip(menu.isVeg),
                      SizedBox(width: 8.w),
                      _buildAvailabilityChip(menu.isAvailable),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        menu.category.isNotEmpty ? menu.category : 'No Category',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.timer,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${menu.preparationTime} min',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    AppUtils.formatCurrency(menu.price),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Action Buttons
            Column(
              children: [
                IconButton(
                  onPressed: () => _showMenuDialog(controller, menu: menu),
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  tooltip: 'Edit Menu Item',
                ),
                
                IconButton(
                  onPressed: () => controller.toggleMenuAvailability(menu),
                  icon: Icon(
                    menu.isAvailable ? Icons.visibility_off : Icons.visibility,
                    color: menu.isAvailable ? AppColors.warning : AppColors.success,
                    size: 20.sp,
                  ),
                  tooltip: menu.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                ),
                
                IconButton(
                  onPressed: () => controller.deleteMenu(menu),
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  tooltip: 'Delete Menu Item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVegChip(bool isVeg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isVeg ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isVeg ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isVeg ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            isVeg ? 'Veg' : 'Non-Veg',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isVeg ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvailabilityChip(bool isAvailable) {
    final color = isAvailable ? AppColors.success : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Unavailable',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  void _showMenuDialog(menu_ctrl.MenuController controller, {MenuModel? menu}) {
    final isEdit = menu != null;
    
    if (isEdit) {
      controller.loadMenuForEdit(menu);
    } else {
      controller.clearForm();
    }
    
    Get.dialog(
      Dialog(
        child: Container(
          width: 700.w,
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Menu Item' : 'Add New Menu Item',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Menu Form
                Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: controller.titleController,
                              label: 'Menu Item Name',
                              hintText: 'Enter menu item name',
                              validator: (value) => controller.validateRequired(value, 'Menu item name'),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CustomTextField(
                              controller: controller.categoryController,
                              label: 'Category',
                              hintText: 'Enter category',
                              validator: (value) => controller.validateRequired(value, 'Category'),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      CustomTextField(
                        controller: controller.descriptionController,
                        label: 'Description',
                        hintText: 'Enter menu item description',
                        maxLines: 3,
                        validator: (value) => controller.validateRequired(value, 'Description'),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: controller.priceController,
                              label: 'Price',
                              hintText: 'Enter price',
                              keyboardType: TextInputType.number,
                              validator: (value) => controller.validateNumber(value, 'Price'),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CustomTextField(
                              controller: controller.preparationTimeController,
                              label: 'Preparation Time (minutes)',
                              hintText: 'Enter preparation time',
                              keyboardType: TextInputType.number,
                              validator: (value) => controller.validateNumber(value, 'Preparation time'),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => CustomDropdown<bool>(
                              label: 'Food Type',
                              value: controller.selectedIsVeg.value,
                              items: const [
                                DropdownMenuItem(value: true, child: Text('Vegetarian')),
                                DropdownMenuItem(value: false, child: Text('Non-Vegetarian')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedIsVeg.value = value;
                                }
                              },
                            )),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Obx(() => CustomDropdown<bool>(
                              label: 'Availability',
                              value: controller.selectedIsAvailable.value,
                              items: const [
                                DropdownMenuItem(value: true, child: Text('Available')),
                                DropdownMenuItem(value: false, child: Text('Unavailable')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedIsAvailable.value = value;
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
                                      'Click to upload menu item image',
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
                              await controller.saveMenu();
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
      ),
    );
  }
}
