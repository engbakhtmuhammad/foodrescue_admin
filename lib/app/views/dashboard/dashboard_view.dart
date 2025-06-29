import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';

import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/recent_data_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.put(DashboardController());
    final AuthService authService = Get.find<AuthService>();
    
    return SidebarLayout(
      title: AppStrings.dashboard,
      child: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: dashboardController.refreshDashboard,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(authService),

                SizedBox(height: 32.h),

                // Statistics Cards
                if (authService.isAdmin) ...[
                  _buildAdminDashboard(dashboardController),
                ] else if (authService.isRestaurantOwner) ...[
                  _buildRestaurantOwnerDashboard(dashboardController),
                ],

                SizedBox(height: 32.h),

                // Recent Data Section
                _buildRecentDataSection(dashboardController, authService),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  Widget _buildWelcomeSection(AuthService authService) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
            Get.find<AuthService>().currentUser.value?.name ?? 'User',
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.textWhite.withOpacity(0.9),
            ),
          )),
          SizedBox(height: 16.h),
          Text(
            'Here\'s what\'s happening with your ${authService.isAdmin ? 'platform' : 'restaurant'} today.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdminDashboard(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reportData,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        // First Row
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalBanners,
                value: controller.totalBanners.value.toString(),
                icon: Icons.image,
                color: AppColors.dashboardCard1,
                onTap: () => Get.toNamed('/banners'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalCuisines,
                value: controller.totalCuisines.value.toString(),
                icon: Icons.restaurant,
                color: AppColors.dashboardCard2,
                onTap: () => Get.toNamed('/cuisines'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalRestaurants,
                value: controller.totalRestaurants.value.toString(),
                icon: Icons.store,
                color: AppColors.dashboardCard3,
                onTap: () => Get.toNamed('/restaurants'),
              )),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        // Second Row
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalFacilities,
                value: controller.totalFacilities.value.toString(),
                icon: Icons.local_offer,
                color: AppColors.dashboardCard4,
                onTap: () => Get.toNamed('/facilities'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalUsers,
                value: controller.totalUsers.value.toString(),
                icon: Icons.people,
                color: AppColors.dashboardCard5,
                onTap: () => Get.toNamed('/users'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.totalEarnings,
                value: '\$${controller.totalEarnings.value.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppColors.dashboardCard6,
                onTap: () => Get.toNamed('/orders'),
              )),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        // Third Row
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.pendingPayouts,
                value: '\$${controller.pendingPayouts.value.toStringAsFixed(2)}',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                onTap: () => Get.toNamed('/payouts'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: AppStrings.completedPayouts,
                value: '\$${controller.completedPayouts.value.toStringAsFixed(2)}',
                icon: Icons.check_circle,
                color: AppColors.success,
                onTap: () => Get.toNamed('/payouts'),
              )),
            ),
            SizedBox(width: 16.w),
            const Expanded(child: SizedBox()), // Empty space
          ],
        ),
      ],
    );
  }
  
  Widget _buildRestaurantOwnerDashboard(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant Overview',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        // First Row
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Gallery Categories',
                value: controller.restaurantGalleryCategories.value.toString(),
                icon: Icons.category,
                color: AppColors.dashboardCard1,
                onTap: () => Get.toNamed('/gallery-categories'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Gallery Images',
                value: controller.restaurantGalleries.value.toString(),
                icon: Icons.photo_library,
                color: AppColors.dashboardCard2,
                onTap: () => Get.toNamed('/galleries'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Surprise Bags',
                value: controller.restaurantSurpriseBags.value.toString(),
                icon: Icons.card_giftcard,
                color: AppColors.dashboardCard3,
                onTap: () => Get.toNamed('/surprise-bags'),
              )),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        // Second Row
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Table Bookings',
                value: controller.restaurantBookings.value.toString(),
                icon: Icons.table_restaurant,
                color: AppColors.dashboardCard4,
                onTap: () => Get.toNamed('/bookings'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Orders',
                value: controller.restaurantOrders.value.toString(),
                icon: Icons.receipt,
                color: AppColors.dashboardCard5,
                onTap: () => Get.toNamed('/orders'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Total Earnings',
                value: '\$${controller.restaurantEarnings.value.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: AppColors.dashboardCard6,
              )),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Third Row - Surprise Bag Details
        Row(
          children: [
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Active Bags',
                value: controller.restaurantActiveSurpriseBags.value.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
                onTap: () => Get.toNamed('/surprise-bags'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Sold Out Bags',
                value: controller.restaurantSoldSurpriseBags.value.toString(),
                icon: Icons.remove_circle,
                color: AppColors.error,
                onTap: () => Get.toNamed('/surprise-bags'),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => DashboardCard(
                title: 'Menu Items',
                value: controller.restaurantMenus.value.toString(),
                icon: Icons.menu_book,
                color: AppColors.dashboardCard1,
                onTap: () => Get.toNamed('/menus'),
              )),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRecentDataSection(DashboardController controller, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Orders
            Expanded(
              child: RecentDataWidget(
                title: 'Recent Orders',
                icon: Icons.receipt,
                items: controller.recentOrders.map((order) => {
                  'title': 'Order #${order.id.substring(0, 8)}',
                  'subtitle': '\$${order.totalAmount.toStringAsFixed(2)}',
                  'status': order.status,
                }).toList(),
                onViewAll: () => Get.toNamed('/orders'),
              ),
            ),
            
            if (authService.isAdmin) ...[
              SizedBox(width: 16.w),
              
              // Recent Users
              Expanded(
                child: RecentDataWidget(
                  title: 'Recent Users',
                  icon: Icons.people,
                  items: controller.recentUsers.map((user) => {
                    'title': user.name,
                    'subtitle': user.email,
                    'status': user.isActive ? 'active' : 'inactive',
                  }).toList(),
                  onViewAll: () => Get.toNamed('/users'),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Recent Restaurants
              Expanded(
                child: RecentDataWidget(
                  title: 'Recent Restaurants',
                  icon: Icons.store,
                  items: controller.recentRestaurants.map((restaurant) => {
                    'title': restaurant.title,
                    'subtitle': restaurant.area,
                    'status': restaurant.status,
                  }).toList(),
                  onViewAll: () => Get.toNamed('/restaurants'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
