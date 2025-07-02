import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';

class SidebarLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const SidebarLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280.w,
            color: AppColors.sidebarBackground,
            child: Column(
              children: [
                // Logo Section
                Container(
                  padding: EdgeInsets.all(24.w),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: AppColors.textWhite,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sidebarText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Divider(color: AppColors.sidebarIcon.withOpacity(0.3)),
                
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: _buildNavigationItems(authService),
                  ),
                ),
                
                Divider(color: AppColors.sidebarIcon.withOpacity(0.3)),
                
                // User Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Obx(() => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            authService.currentUser.value?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          authService.currentUser.value?.name ?? 'User',
                          style: TextStyle(
                            color: AppColors.sidebarText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          authService.currentUser.value?.role ?? 'Role',
                          style: TextStyle(
                            color: AppColors.sidebarIcon,
                            fontSize: 12.sp,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      )),
                      
                      SizedBox(height: 8.h),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authService.signOut,
                          icon: Icon(Icons.logout, size: 16.sp),
                          label: Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.textWhite,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 80.h,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Refresh functionality
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildNavigationItems(AuthService authService) {
    final List<NavigationItem> items = [];
    
    // Common items
    items.add(NavigationItem(
      icon: Icons.dashboard,
      title: AppStrings.dashboard,
      route: AppRoutes.dashboard,
    ));
    
    if (authService.isAdmin) {
      // Admin items
      items.addAll([
        NavigationItem(
          icon: Icons.store,
          title: AppStrings.restaurants,
          route: AppRoutes.restaurants,
        ),
        NavigationItem(
          icon: Icons.people,
          title: AppStrings.users,
          route: AppRoutes.users,
        ),
        NavigationItem(
          icon: Icons.receipt,
          title: AppStrings.orders,
          route: AppRoutes.orders,
        ),
        NavigationItem(
          icon: Icons.image,
          title: AppStrings.banners,
          route: AppRoutes.banners,
        ),
        NavigationItem(
          icon: Icons.restaurant,
          title: AppStrings.cuisines,
          route: AppRoutes.cuisines,
        ),
        NavigationItem(
          icon: Icons.local_offer,
          title: AppStrings.facilities,
          route: AppRoutes.facilities,
        ),
        NavigationItem(
          icon: Icons.help,
          title: AppStrings.faqs,
          route: AppRoutes.faqs,
        ),
        NavigationItem(
          icon: Icons.payment,
          title: 'Payment Gateways',
          route: AppRoutes.paymentGateways,
        ),
        NavigationItem(
          icon: Icons.account_balance_wallet,
          title: AppStrings.payouts,
          route: AppRoutes.payouts,
        ),
      ]);
    } else if (authService.isRestaurantOwner) {
      // Restaurant Owner items
      items.addAll([
        NavigationItem(
          icon: Icons.receipt,
          title: AppStrings.orders,
          route: AppRoutes.orders,
        ),
        NavigationItem(
          icon: Icons.table_restaurant,
          title: 'Bookings',
          route: AppRoutes.restaurantBookings,
        ),
        NavigationItem(
          icon: Icons.menu_book,
          title: AppStrings.menus,
          route: AppRoutes.menus,
        ),
        NavigationItem(
          icon: Icons.card_giftcard,
          title: 'Surprise Bags',
          route: AppRoutes.surpriseBags,
        ),
        NavigationItem(
          icon: Icons.shopping_bag,
          title: 'Bag Orders',
          route: AppRoutes.surpriseBagOrders,
        ),
        NavigationItem(
          icon: Icons.photo_library,
          title: AppStrings.gallery,
          route: AppRoutes.galleries,
        ),
        NavigationItem(
          icon: Icons.table_restaurant,
          title: 'Bookings',
          route: AppRoutes.bookings,
        ),
      ]);
    }
    
    // Settings (common)
    items.add(NavigationItem(
      icon: Icons.settings,
      title: AppStrings.settings,
      route: AppRoutes.settings,
    ));
    
    return items.map((item) => _buildNavigationItem(item)).toList();
  }
  
  Widget _buildNavigationItem(NavigationItem item) {
    final isSelected = Get.currentRoute == item.route;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.sidebarIcon,
          size: 20.sp,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.sidebarText,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.sidebarSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        onTap: () {
          if (!isSelected) {
            Get.toNamed(item.route);
          }
        },
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final String route;

  NavigationItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}
