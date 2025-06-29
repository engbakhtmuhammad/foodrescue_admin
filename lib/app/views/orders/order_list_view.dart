import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_button.dart';
import '../../models/order_model.dart';
import '../../utils/app_utils.dart';

class OrderListView extends StatelessWidget {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());
    
    return SidebarLayout(
      title: AppStrings.orders,
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
                        'Total Orders',
                        controller.totalOrders,
                        Icons.receipt,
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Total Earnings',
                        RxInt(0),
                        Icons.attach_money,
                        AppColors.success,
                        isCurrency: true,
                        currencyValue: controller.totalEarnings,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        controller.pendingOrders,
                        Icons.pending,
                        AppColors.warning,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        controller.completedOrders,
                        Icons.check_circle,
                        AppColors.success,
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
                        hintText: 'Search orders by ID, customer, or restaurant...',
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
                          const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          const DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                          const DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          const DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
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
                    
                    // Date Range Filter
                    CustomButton(
                      text: 'Date Range',
                      icon: Icons.date_range,
                      outlined: true,
                      onPressed: () => _showDateRangePicker(context, controller),
                    ),
                    
                    SizedBox(width: 16.w),
                    
                    // Export Button
                    CustomButton(
                      text: 'Export',
                      icon: Icons.download,
                      onPressed: controller.exportOrders,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Orders List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Orders will appear here when customers place them',
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
                onRefresh: controller.refreshOrders,
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredOrders.length + 
                      (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredOrders.length) {
                      // Load more indicator
                      controller.loadOrders();
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    final order = controller.filteredOrders[index];
                    return _buildOrderCard(order, controller);
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
    Color color, {
    bool isCurrency = false,
    RxDouble? currencyValue,
  }) {
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
                    isCurrency 
                        ? AppUtils.formatCurrency(currencyValue?.value ?? 0.0)
                        : value.value.toString(),
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
  
  Widget _buildOrderCard(OrderModel order, OrderController controller) {
    final user = controller.getUserForOrder(order.uid);
    final restaurant = controller.getRestaurantForOrder(order.restId);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppUtils.formatDateTime(order.orderDate),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(order.status),
                SizedBox(width: 16.w),
                _buildStatusUpdateButton(order, controller),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Customer and Restaurant Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user?.name ?? 'Unknown Customer',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user?.email != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          user!.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        restaurant?.title ?? 'Unknown Restaurant',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (restaurant?.area != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          restaurant!.area,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Order Details
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  _buildOrderDetailRow('Total Amount', AppUtils.formatCurrency(order.totalAmount)),
                  if (order.discountAmount > 0) ...[
                    SizedBox(height: 8.h),
                    _buildOrderDetailRow('Discount', '-${AppUtils.formatCurrency(order.discountAmount)}'),
                  ],
                  if (order.tipAmount > 0) ...[
                    SizedBox(height: 8.h),
                    _buildOrderDetailRow('Tip', AppUtils.formatCurrency(order.tipAmount)),
                  ],
                  if (order.walletAmount > 0) ...[
                    SizedBox(height: 8.h),
                    _buildOrderDetailRow('Wallet Used', '-${AppUtils.formatCurrency(order.walletAmount)}'),
                  ],
                  SizedBox(height: 8.h),
                  Divider(color: AppColors.border),
                  SizedBox(height: 8.h),
                  _buildOrderDetailRow(
                    'Paid Amount', 
                    AppUtils.formatCurrency(order.payedAmount),
                    isTotal: true,
                  ),
                ],
              ),
            ),
            
            if (order.items.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'Order Items (${order.items.length})',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              ...order.items.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.menuName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      AppUtils.formatCurrency(item.totalPrice),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    final color = AppUtils.getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
  
  Widget _buildStatusUpdateButton(OrderModel order, OrderController controller) {
    final availableStatuses = controller.getAvailableStatusOptions(order.status);
    
    if (availableStatuses.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20.sp),
      onSelected: (status) => controller.updateOrderStatus(order, status),
      itemBuilder: (context) => availableStatuses
          .map((status) => PopupMenuItem<String>(
                value: status,
                child: Text('Mark as ${controller.getStatusDisplayName(status)}'),
              ))
          .toList(),
    );
  }
  
  Widget _buildOrderDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14.sp : 12.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14.sp : 12.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  void _showDateRangePicker(BuildContext context, OrderController controller) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );
    
    if (picked != null) {
      controller.setDateRangeFilter(picked);
    }
  }
}
