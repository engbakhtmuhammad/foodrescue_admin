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
import '../../models/restaurant_model.dart';
import '../../utils/app_utils.dart';

class RestaurantListView extends StatelessWidget {
  const RestaurantListView({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantController controller = Get.put(RestaurantController());
    
    return SidebarLayout(
      title: AppStrings.restaurants,
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
                        hintText: 'Search restaurants...',
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
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All Status')),
                          const DropdownMenuItem(value: 'active', child: Text('Active')),
                          const DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
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
                    
                    // Add Restaurant Button
                    CustomButton(
                      text: AppStrings.addRestaurant,
                      icon: Icons.add,
                      onPressed: () => Get.toNamed('/add-restaurant'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Restaurant List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.restaurants.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredRestaurants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No restaurants found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first restaurant to get started',
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
                onRefresh: () => controller.loadRestaurants(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredRestaurants.length + 
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredRestaurants.length) {
                      // Load more indicator
                      controller.loadRestaurants();
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final restaurant = controller.filteredRestaurants[index];
                    return _buildRestaurantCard(restaurant, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRestaurantCard(RestaurantModel restaurant, RestaurantController controller) {
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
            // Restaurant Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: restaurant.img,
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
            
            // Restaurant Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusChip(restaurant.status),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${restaurant.area}, ${restaurant.fullAddress}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        restaurant.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.phone,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        restaurant.mobile,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.star,
                        label: restaurant.rating.toString(),
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8.w),
                      _buildInfoChip(
                        icon: Icons.attach_money,
                        label: restaurant.approxPrice.toString(),
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8.w),
                      _buildInfoChip(
                        icon: restaurant.tShow ? Icons.table_restaurant : Icons.no_meals,
                        label: restaurant.tShow ? 'Booking' : 'No Booking',
                        color: restaurant.tShow ? AppColors.info : AppColors.textHint,
                      ),
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
                    controller.loadRestaurantForEdit(restaurant);
                    Get.toNamed('/edit-restaurant');
                  },
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  tooltip: 'Edit Restaurant',
                ),
                
                IconButton(
                  onPressed: () => controller.toggleRestaurantStatus(restaurant),
                  icon: Icon(
                    restaurant.status == 'active' ? Icons.visibility_off : Icons.visibility,
                    color: restaurant.status == 'active' ? AppColors.warning : AppColors.success,
                    size: 20.sp,
                  ),
                  tooltip: restaurant.status == 'active' ? 'Deactivate' : 'Activate',
                ),
                
                IconButton(
                  onPressed: () => controller.deleteRestaurant(restaurant),
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  tooltip: 'Delete Restaurant',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        AppUtils.capitalizeFirst(status),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
