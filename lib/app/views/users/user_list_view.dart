import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/user_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/user_model.dart';
import '../../utils/app_utils.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());
    
    return SidebarLayout(
      title: AppStrings.users,
      child: Column(
        children: [
          // Header with search and filters
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Column(
              children: [
                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Users',
                        controller.totalUsers,
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Active Users',
                        controller.activeUsers,
                        Icons.person,
                        AppColors.success,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Admins',
                        controller.adminUsers,
                        Icons.admin_panel_settings,
                        AppColors.warning,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Restaurant Owners',
                        controller.restaurantOwners,
                        Icons.store,
                        AppColors.info,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Search and Filter Row
                Row(
                  children: [
                    // Search Field
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.searchController,
                        label: '',
                        hintText: 'Search users by name, email, or mobile...',
                        prefixIcon: Icons.search,
                      ),
                    ),
                    
                    SizedBox(width: 16.w),
                    
                    // Role Filter
                    Expanded(
                      flex: 2,
                      child: Obx(() => CustomDropdown<String>(
                        label: '',
                        value: controller.selectedRoleFilter.value,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Roles')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'restaurant_owner', child: Text('Restaurant Owner')),
                          DropdownMenuItem(value: 'customer', child: Text('Customer')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.setRoleFilter(value);
                          }
                        },
                        prefixIcon: Icons.person,
                      )),
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
                  ],
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Users will appear here when they register',
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
                onRefresh: () => controller.loadUsers(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredUsers.length + 
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredUsers.length) {
                      // Load more indicator
                      controller.loadUsers();
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final user = controller.filteredUsers[index];
                    return _buildUserCard(user, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(
    String title,
    RxInt value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    value.value.toString(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserCard(UserModel user, UserController controller) {
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
            // User Avatar
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: user.profileImage != null 
                  ? CachedNetworkImageProvider(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            
            SizedBox(width: 16.w),
            
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildRoleChip(user.role),
                      SizedBox(width: 8.w),
                      _buildStatusChip(user.isActive ? 'active' : 'inactive'),
                    ],
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (user.mobile != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${user.ccode ?? ''}${user.mobile}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 8.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Joined ${AppUtils.formatDate(user.createdAt)}',
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
            
            SizedBox(width: 16.w),
            
            // Action Buttons
            Column(
              children: [
                IconButton(
                  onPressed: () => controller.toggleUserStatus(user),
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    color: user.isActive ? AppColors.error : AppColors.success,
                    size: 20.sp,
                  ),
                  tooltip: user.isActive ? 'Deactivate User' : 'Activate User',
                ),
                
                IconButton(
                  onPressed: () => _showUserDetails(user),
                  icon: Icon(
                    Icons.visibility,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  tooltip: 'View Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRoleChip(String role) {
    Color color;
    String displayRole;
    
    switch (role) {
      case 'admin':
        color = AppColors.error;
        displayRole = 'Admin';
        break;
      case 'restaurant_owner':
        color = AppColors.warning;
        displayRole = 'Restaurant Owner';
        break;
      case 'customer':
        color = AppColors.info;
        displayRole = 'Customer';
        break;
      default:
        color = AppColors.textSecondary;
        displayRole = AppUtils.capitalizeFirst(role);
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayRole,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        AppUtils.capitalizeFirst(status),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  void _showUserDetails(UserModel user) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'User Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // User Info
              _buildDetailRow('Name', user.name),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', AppUtils.capitalizeFirst(user.role)),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              if (user.mobile != null)
                _buildDetailRow('Mobile', '${user.ccode ?? ''}${user.mobile}'),
              _buildDetailRow('Joined', AppUtils.formatDateTime(user.createdAt)),
              _buildDetailRow('Last Updated', AppUtils.formatDateTime(user.updatedAt)),
              
              SizedBox(height: 24.h),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
