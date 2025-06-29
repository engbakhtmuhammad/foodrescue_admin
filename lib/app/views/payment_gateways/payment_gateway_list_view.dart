import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/payment_gateway_controller.dart';
import '../../constants/app_colors.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/payment_gateway_model.dart';

class PaymentGatewayListView extends StatelessWidget {
  const PaymentGatewayListView({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentGatewayController controller = Get.put(PaymentGatewayController());
    
    return SidebarLayout(
      title: 'Payment Gateways',
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
                    hintText: 'Search payment gateways...',
                    prefixIcon: Icons.search,
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Type Filter
                Expanded(
                  child: Obx(() => CustomDropdown<String>(
                    label: '',
                    value: controller.selectedTypeFilter.value,
                    hintText: 'All Types',
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Types')),
                      ...PaymentGatewayModel.gatewayTypes.map((type) => 
                        DropdownMenuItem(
                          value: type, 
                          child: Text(PaymentGatewayModel.getGatewayTypeDisplayName(type)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setTypeFilter(value);
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
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setStatusFilter(value);
                      }
                    },
                  )),
                ),
                
                SizedBox(width: 16.w),
                
                // Add Button
                CustomButton(
                  text: 'Add Gateway',
                  onPressed: () => _showPaymentGatewayDialog(context, controller),
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          
          // Payment Gateways List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.paymentGateways.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredPaymentGateways.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No payment gateways found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first payment gateway to get started',
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
                onRefresh: () => controller.loadPaymentGateways(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredPaymentGateways.length,
                  itemBuilder: (context, index) {
                    final gateway = controller.filteredPaymentGateways[index];
                    return _buildPaymentGatewayCard(gateway, controller, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentGatewayCard(PaymentGatewayModel gateway, PaymentGatewayController controller, BuildContext context) {
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
            // Logo
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: gateway.logoUrl?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: gateway.logoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Icon(
                          Icons.payment,
                          color: AppColors.textHint,
                          size: 24.sp,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.payment,
                          color: AppColors.textHint,
                          size: 24.sp,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.payment,
                      color: AppColors.textHint,
                      size: 24.sp,
                    ),
            ),
            
            SizedBox(width: 16.w),
            
            // Gateway Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gateway.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildStatusBadge(gateway.isActive),
                      if (gateway.isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  Text(
                    PaymentGatewayModel.getGatewayTypeDisplayName(gateway.type),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  if (gateway.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      gateway.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textHint,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  SizedBox(height: 8.h),
                  
                  // Fee Information
                  Row(
                    children: [
                      if (gateway.transactionFeePercentage > 0) ...[
                        Text(
                          '${gateway.transactionFeePercentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (gateway.fixedTransactionFee > 0) ...[
                          Text(
                            ' + ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                      if (gateway.fixedTransactionFee > 0) ...[
                        Text(
                          '\$${gateway.fixedTransactionFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (gateway.transactionFeePercentage == 0 && gateway.fixedTransactionFee == 0) ...[
                        Text(
                          'No fees',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Supported Currencies
                      Text(
                        gateway.supportedCurrencies.join(', '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
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
                  onPressed: () {
                    controller.loadPaymentGatewayForEdit(gateway);
                    _showPaymentGatewayDialog(context, controller);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  tooltip: 'Edit Gateway',
                ),
                
                if (!gateway.isDefault) ...[
                  IconButton(
                    onPressed: () => controller.setAsDefaultGateway(gateway),
                    icon: Icon(
                      Icons.star_border,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                    tooltip: 'Set as Default',
                  ),
                ],
                
                IconButton(
                  onPressed: () => controller.togglePaymentGatewayStatus(gateway),
                  icon: Icon(
                    gateway.isActive ? Icons.visibility_off : Icons.visibility,
                    color: gateway.isActive ? AppColors.warning : AppColors.success,
                    size: 20.sp,
                  ),
                  tooltip: gateway.isActive ? 'Deactivate' : 'Activate',
                ),
                
                IconButton(
                  onPressed: () => _showDeleteDialog(context, controller, gateway),
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                  tooltip: 'Delete Gateway',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  void _showPaymentGatewayDialog(BuildContext context, PaymentGatewayController controller) {
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
                      controller.currentPaymentGateway.value != null
                          ? 'Edit Payment Gateway'
                          : 'Add New Payment Gateway',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Name and Type Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.nameController,
                            label: 'Gateway Name',
                            hintText: 'Enter gateway name',
                            validator: (value) => controller.validateRequired(value, 'Name'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Obx(() => CustomDropdown<String>(
                            label: 'Gateway Type',
                            value: controller.selectedType.value,
                            items: PaymentGatewayModel.gatewayTypes.map((type) =>
                              DropdownMenuItem(
                                value: type,
                                child: Text(PaymentGatewayModel.getGatewayTypeDisplayName(type)),
                              ),
                            ).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedType.value = value;
                              }
                            },
                          )),
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
                          text: controller.currentPaymentGateway.value != null
                              ? 'Update Gateway'
                              : 'Create Gateway',
                          onPressed: controller.isLoading.value ? null : () async {
                            await controller.savePaymentGateway();
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

  void _showDeleteDialog(BuildContext context, PaymentGatewayController controller, PaymentGatewayModel gateway) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Payment Gateway'),
          content: Text('Are you sure you want to delete "${gateway.name}"?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deletePaymentGateway(gateway);
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
