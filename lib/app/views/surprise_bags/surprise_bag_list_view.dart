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
import '../../models/surprise_bag_model.dart';

class SurpriseBagListView extends StatelessWidget {
  const SurpriseBagListView({super.key});

  @override
  Widget build(BuildContext context) {
    final SurpriseBagController controller = Get.put(SurpriseBagController());
    
    return SidebarLayout(
      title: 'Surprise Bags',
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
                    hintText: 'Search surprise bags...',
                    prefixIcon: Icons.search,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Category Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedCategoryFilter.value,
                    hintText: 'All Categories',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      ...controller.categories.map((category) => 
                        DropdownMenuItem(value: category, child: Text(category)),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCategoryFilter.value = value;
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Status Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedStatusFilter.value,
                    hintText: 'All Status',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'sold_out', child: Text('Sold Out')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedStatusFilter.value = value;
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Button
                CustomButton(
                  text: 'Add Surprise Bag',
                  onPressed: () => Get.toNamed('/add-surprise-bag'),
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          
          // Surprise Bags List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.surpriseBags.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredSurpriseBags.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No surprise bags found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create your first surprise bag to get started',
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
                onRefresh: () => controller.loadSurpriseBags(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredSurpriseBags.length,
                  itemBuilder: (context, index) {
                    final bag = controller.filteredSurpriseBags[index];
                    return _buildSurpriseBagCard(bag, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSurpriseBagCard(SurpriseBagModel bag, SurpriseBagController controller) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: bag.img,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80.w,
                  height: 80.w,
                  color: AppColors.background,
                  child: Icon(
                    Icons.card_giftcard,
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
            
            // Bag Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bag.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusChip(bag.status),
                      SizedBox(width: 8.w),
                      _buildAvailabilityChip(bag.isAvailable),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Text(
                    bag.description,
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
                      // Original Price (crossed out)
                      Text(
                        '\$${bag.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      
                      SizedBox(width: 8.w),
                      
                      // Discounted Price
                      Text(
                        '\$${bag.discountedPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      
                      SizedBox(width: 8.w),
                      
                      // Discount Percentage
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${bag.calculatedDiscountPercentage.toStringAsFixed(0)}% OFF',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Items Left
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: bag.itemsLeft > 0 ? AppColors.primary.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${bag.itemsLeft} left',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: bag.itemsLeft > 0 ? AppColors.primary : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Pickup Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _getPickupTimeText(bag),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      

                      
                      if (bag.category.isNotEmpty) ...[
                        SizedBox(width: 16.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            bag.category,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Action Buttons
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    controller.loadSurpriseBagForEdit(bag);
                    Get.toNamed('/edit-surprise-bag');
                  },
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  tooltip: 'Edit Surprise Bag',
                ),
                
                IconButton(
                  onPressed: () => controller.toggleSurpriseBagAvailability(bag),
                  icon: Icon(
                    bag.isAvailable ? Icons.visibility_off : Icons.visibility,
                    color: bag.isAvailable ? AppColors.warning : AppColors.success,
                    size: 20.sp,
                  ),
                  tooltip: bag.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                ),
                
                IconButton(
                  onPressed: () => controller.deleteSurpriseBag(bag),
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  tooltip: 'Delete Surprise Bag',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = AppColors.success;
        text = 'Active';
        break;
      case 'inactive':
        color = AppColors.warning;
        text = 'Inactive';
        break;
      case 'sold_out':
        color = AppColors.error;
        text = 'Sold Out';
        break;
      default:
        color = AppColors.textSecondary;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip(bool isAvailable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Unavailable',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isAvailable ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  String _getPickupTimeText(SurpriseBagModel bag) {
    if (bag.pickupType == 'today' && bag.todayPickupRange.isNotEmpty) {
      return 'Today: ${bag.todayPickupRange}';
    } else if (bag.pickupType == 'tomorrow' && bag.tomorrowPickupRange.isNotEmpty) {
      return 'Tomorrow: ${bag.tomorrowPickupRange}';
    } else if (bag.pickupType == 'both') {
      final today = bag.todayPickupRange.isNotEmpty ? 'Today: ${bag.todayPickupRange}' : '';
      final tomorrow = bag.tomorrowPickupRange.isNotEmpty ? 'Tomorrow: ${bag.tomorrowPickupRange}' : '';
      if (today.isNotEmpty && tomorrow.isNotEmpty) {
        return '$today, $tomorrow';
      } else if (today.isNotEmpty) {
        return today;
      } else if (tomorrow.isNotEmpty) {
        return tomorrow;
      }
    }
    return 'Pickup time not set';
  }
}
