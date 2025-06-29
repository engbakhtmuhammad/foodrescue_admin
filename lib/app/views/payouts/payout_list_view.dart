import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/payout_controller.dart';
import '../../constants/app_colors.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/payout_model.dart';

class PayoutListView extends StatelessWidget {
  const PayoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    final PayoutController controller = Get.put(PayoutController());
    
    return SidebarLayout(
      title: 'Payouts Management',
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
                    hintText: 'Search payouts...',
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
                      ...PayoutModel.statuses.map((status) => 
                        DropdownMenuItem(
                          value: status, 
                          child: Text(PayoutModel.getStatusDisplayName(status)),
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
                
                // Payment Method Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedPaymentMethodFilter.value,
                    hintText: 'All Methods',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Methods')),
                      ...PayoutModel.paymentMethods.map((method) => 
                        DropdownMenuItem(
                          value: method, 
                          child: Text(PayoutModel.getPaymentMethodDisplayName(method)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setPaymentMethodFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Restaurant Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedRestaurantFilter.value,
                    hintText: 'All Restaurants',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Restaurants')),
                      ...controller.restaurants.map((restaurant) => 
                        DropdownMenuItem(
                          value: restaurant.id, 
                          child: Text(restaurant.title),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setRestaurantFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Button
                CustomButton(
                  text: 'Create Payout',
                  onPressed: () => _showPayoutDialog(context, controller),
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          
          // Payouts List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.payouts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredPayouts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No payouts found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create your first payout to get started',
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
                onRefresh: () => controller.loadPayouts(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredPayouts.length,
                  itemBuilder: (context, index) {
                    final payout = controller.filteredPayouts[index];
                    return _buildPayoutCard(payout, controller, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPayoutCard(PayoutModel payout, PayoutController controller, BuildContext context) {
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
                        payout.restaurantName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        payout.restaurantOwnerEmail,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                _buildStatusBadge(payout.status),
                
                SizedBox(width: 16.w),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.loadPayoutForEdit(payout);
                        _showPayoutDialog(context, controller);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      tooltip: 'Edit Payout',
                    ),
                    if (payout.status == 'pending') ...[
                      IconButton(
                        onPressed: () => controller.updatePayoutStatus(payout, 'processing'),
                        icon: Icon(
                          Icons.play_arrow,
                          color: AppColors.warning,
                          size: 20.sp,
                        ),
                        tooltip: 'Start Processing',
                      ),
                    ],
                    if (payout.status == 'processing') ...[
                      IconButton(
                        onPressed: () => controller.updatePayoutStatus(payout, 'completed'),
                        icon: Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 20.sp,
                        ),
                        tooltip: 'Mark Completed',
                      ),
                    ],
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, controller, payout),
                      icon: Icon(
                        Icons.delete,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      tooltip: 'Delete Payout',
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Amount Information
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Amount', '\$${payout.amount.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Commission', '\$${payout.commissionAmount.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Net Amount', '\$${payout.netAmount.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem('Payment Method', PayoutModel.getPaymentMethodDisplayName(payout.paymentMethod)),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Period Information
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Period Start', DateFormat('MMM dd, yyyy').format(payout.periodStart)),
                ),
                Expanded(
                  child: _buildInfoItem('Period End', DateFormat('MMM dd, yyyy').format(payout.periodEnd)),
                ),
                Expanded(
                  child: _buildInfoItem('Requested', DateFormat('MMM dd, yyyy').format(payout.requestedAt)),
                ),
                Expanded(
                  child: _buildInfoItem('Transaction ID', payout.transactionId ?? 'N/A'),
                ),
              ],
            ),
            
            // Notes if available
            if (payout.notes?.isNotEmpty == true) ...[
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
                      'Notes:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      payout.notes!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'processing':
        color = AppColors.primary;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'cancelled':
        color = AppColors.textSecondary;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        PayoutModel.getStatusDisplayName(status),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
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
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showPayoutDialog(BuildContext context, PayoutController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            width: 800.w,
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentPayout.value != null ? 'Edit Payout' : 'Create New Payout',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Restaurant and Status Row
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => CustomDropdown<String>(
                            label: 'Restaurant',
                            value: controller.selectedRestaurantId.value.isEmpty
                                ? null
                                : controller.selectedRestaurantId.value,
                            items: controller.restaurants.map((restaurant) =>
                              DropdownMenuItem(
                                value: restaurant.id,
                                child: Text(restaurant.title),
                              ),
                            ).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedRestaurantId.value = value;
                              }
                            },
                            validator: (value) => controller.validateRequired(value, 'Restaurant'),
                          )),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Obx(() => CustomDropdown<String>(
                            label: 'Status',
                            value: controller.selectedStatus.value,
                            items: PayoutModel.statuses.map((status) =>
                              DropdownMenuItem(
                                value: status,
                                child: Text(PayoutModel.getStatusDisplayName(status)),
                              ),
                            ).toList(),
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

                    // Amount and Commission Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.amountController,
                            label: 'Total Amount',
                            hintText: 'Enter total amount',
                            keyboardType: TextInputType.number,
                            validator: (value) => controller.validatePositiveNumber(value, 'Amount'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CustomTextField(
                            controller: controller.commissionController,
                            label: 'Commission Amount',
                            hintText: 'Enter commission amount',
                            keyboardType: TextInputType.number,
                            validator: (value) => controller.validateNumber(value, 'Commission'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.clearForm();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Obx(() => CustomButton(
                          text: controller.currentPayout.value != null ? 'Update Payout' : 'Create Payout',
                          onPressed: controller.isLoading.value ? null : () async {
                            await controller.savePayout();
                            if (!controller.isLoading.value) {
                              Navigator.of(context).pop();
                            }
                          },
                          isLoading: controller.isLoading.value,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, PayoutController controller, PayoutModel payout) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Payout'),
          content: Text('Are you sure you want to delete this payout for ${payout.restaurantName}?\n\nAmount: \$${payout.amount.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deletePayout(payout);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
