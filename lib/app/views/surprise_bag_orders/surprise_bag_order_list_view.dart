import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/surprise_bag_order_controller.dart';
import '../../constants/app_colors.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_button.dart';
import '../../models/surprise_bag_order_model.dart';

class SurpriseBagOrderListView extends StatelessWidget {
  const SurpriseBagOrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    final SurpriseBagOrderController controller = Get.put(SurpriseBagOrderController());
    
    return SidebarLayout(
      title: 'Surprise Bag Orders',
      child: Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Obx(() => Row(
              children: [
                _buildStatCard(
                  'Total Orders',
                  controller.orders.length.toString(),
                  Icons.shopping_bag,
                  AppColors.primary,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Pending',
                  controller.getOrdersCountByStatus('pending').toString(),
                  Icons.pending,
                  AppColors.warning,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Ready',
                  controller.getOrdersCountByStatus('ready').toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Today\'s Revenue',
                  '\$${controller.getTodaysRevenue().toStringAsFixed(2)}',
                  Icons.attach_money,
                  AppColors.info,
                ),
              ],
            )),
          ),
          
          // Header with search and filters
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.background,
            child: Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: controller.searchController,
                    label: '',
                    hintText: 'Search orders by customer name, email, or bag title...',
                    prefixIcon: Icons.search,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Status Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedStatusFilter.value,
                    hintText: 'All Status',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Status')),
                      ...SurpriseBagOrderModel.statuses.map((status) => 
                        DropdownMenuItem(
                          value: status, 
                          child: Text(SurpriseBagOrderModel.getStatusDisplayName(status)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStatusFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Payment Status Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedPaymentStatusFilter.value,
                    hintText: 'All Payments',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Payments')),
                      ...SurpriseBagOrderModel.paymentStatuses.map((status) => 
                        DropdownMenuItem(
                          value: status, 
                          child: Text(SurpriseBagOrderModel.getPaymentStatusDisplayName(status)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setPaymentStatusFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Date Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedDateFilter.value,
                    hintText: 'All Dates',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Dates')),
                      DropdownMenuItem(value: 'today', child: Text('Today')),
                      DropdownMenuItem(value: 'tomorrow', child: Text('Tomorrow')),
                      DropdownMenuItem(value: 'this_week', child: Text('This Week')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setDateFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Refresh Button
                CustomButton(
                  text: 'Refresh',
                  onPressed: () => controller.loadOrders(refresh: true),
                  icon: Icons.refresh,
                  outlined: true,
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
                        Icons.shopping_bag_outlined,
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
                        'Orders will appear here when customers reserve surprise bags',
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
                onRefresh: () => controller.loadOrders(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return _buildOrderCard(order, controller, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
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
  
  Widget _buildOrderCard(SurpriseBagOrderModel order, SurpriseBagOrderController controller, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                        order.surpriseBagTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Order #${order.id.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(order.status),
                    SizedBox(height: 4.h),
                    _buildPaymentStatusBadge(order.paymentStatus),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Customer and Order Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Customer', order.userName),
                ),
                Expanded(
                  child: _buildInfoItem('Phone', order.userPhone),
                ),
                Expanded(
                  child: _buildInfoItem('Pickup Date', DateFormat('MMM dd, yyyy').format(order.pickupDate)),
                ),
                Expanded(
                  child: _buildInfoItem('Pickup Time', order.pickupTimeSlot),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Price and Payment Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Quantity', order.quantity.toString()),
                ),
                Expanded(
                  child: _buildInfoItem('Original Price', '\$${order.originalPrice.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Discounted Price', '\$${order.discountedPrice.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Total Amount', '\$${order.totalAmount.toStringAsFixed(2)}'),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Order Date and Email
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Email', order.userEmail),
                ),
                Expanded(
                  child: _buildInfoItem('Order Date', DateFormat('MMM dd, yyyy HH:mm').format(order.orderDate)),
                ),
                Expanded(
                  child: _buildInfoItem('Payment Method', order.paymentMethod.isNotEmpty ? order.paymentMethod : 'N/A'),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            
            // Customer Notes if available
            if (order.customerNotes != null && order.customerNotes!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Notes:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.customerNotes!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Restaurant Notes if available
            if (order.restaurantNotes != null && order.restaurantNotes!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Notes:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.restaurantNotes!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 16.h),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.canBeConfirmed) ...[
                  CustomButton(
                    text: 'Confirm Order',
                    onPressed: () => _showConfirmDialog(context, controller, order),
                    icon: Icons.check,
                    outlined: false,
                  ),
                  SizedBox(width: 8.w),
                ],
                if (order.canBeMarkedReady) ...[
                  CustomButton(
                    text: 'Mark Ready',
                    onPressed: () => _showMarkReadyDialog(context, controller, order),
                    icon: Icons.done,
                    outlined: false,
                  ),
                  SizedBox(width: 8.w),
                ],
                if (order.canBeCompleted) ...[
                  CustomButton(
                    text: 'Complete',
                    onPressed: () => controller.updateOrderStatus(order, 'completed'),
                    icon: Icons.done_all,
                    outlined: false,
                  ),
                  SizedBox(width: 8.w),
                ],
                if (order.canBeCancelled) ...[
                  CustomButton(
                    text: 'Cancel',
                    onPressed: () => _showCancelDialog(context, controller, order),
                    icon: Icons.cancel,
                    outlined: true,
                    backgroundColor: AppColors.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayText;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        displayText = 'Pending';
        break;
      case 'confirmed':
        color = AppColors.info;
        displayText = 'Confirmed';
        break;
      case 'ready':
        color = AppColors.success;
        displayText = 'Ready';
        break;
      case 'completed':
        color = AppColors.primary;
        displayText = 'Completed';
        break;
      case 'cancelled':
        color = AppColors.error;
        displayText = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String paymentStatus) {
    Color color;
    String displayText;

    switch (paymentStatus) {
      case 'pending':
        color = AppColors.warning;
        displayText = 'Payment Pending';
        break;
      case 'paid':
        color = AppColors.success;
        displayText = 'Paid';
        break;
      case 'refunded':
        color = AppColors.error;
        displayText = 'Refunded';
        break;
      default:
        color = AppColors.textSecondary;
        displayText = paymentStatus.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context, SurpriseBagOrderController controller, SurpriseBagOrderModel order) {
    controller.restaurantNotesController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm the surprise bag order for ${order.userName}?'),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.restaurantNotesController,
              label: 'Restaurant Notes (Optional)',
              hintText: 'Add any special instructions or notes...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.updateOrderStatus(
                order,
                'confirmed',
                notes: controller.restaurantNotesController.text.trim(),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showMarkReadyDialog(BuildContext context, SurpriseBagOrderController controller, SurpriseBagOrderModel order) {
    controller.restaurantNotesController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Order Ready'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark the surprise bag as ready for pickup for ${order.userName}?'),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.restaurantNotesController,
              label: 'Pickup Instructions (Optional)',
              hintText: 'Add pickup instructions for the customer...',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.updateOrderStatus(
                order,
                'ready',
                notes: controller.restaurantNotesController.text.trim(),
              );
            },
            child: const Text('Mark Ready'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, SurpriseBagOrderController controller, SurpriseBagOrderModel order) {
    controller.cancellationReasonController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel the order for ${order.userName}?'),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: controller.cancellationReasonController,
              label: 'Cancellation Reason',
              hintText: 'Please provide a reason for cancellation...',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a cancellation reason';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (controller.cancellationReasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                controller.updateOrderStatus(
                  order,
                  'cancelled',
                  notes: controller.cancellationReasonController.text.trim(),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
