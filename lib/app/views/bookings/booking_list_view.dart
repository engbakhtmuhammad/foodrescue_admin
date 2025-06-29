import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/booking_controller.dart';
import '../../constants/app_colors.dart';
import '../../widgets/sidebar_layout.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../models/booking_model.dart';

class BookingListView extends StatelessWidget {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.put(BookingController());
    
    return SidebarLayout(
      title: 'Bookings Management',
      child: Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppColors.surface,
            child: Obx(() => Row(
              children: [
                _buildStatCard(
                  'Total Bookings',
                  controller.bookings.length.toString(),
                  Icons.event,
                  AppColors.primary,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Pending',
                  controller.getBookingsCountByStatus('pending').toString(),
                  Icons.pending,
                  AppColors.warning,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Confirmed',
                  controller.getBookingsCountByStatus('confirmed').toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
                SizedBox(width: 16.w),
                _buildStatCard(
                  'Today',
                  controller.getTodaysBookings().length.toString(),
                  Icons.today,
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
                    hintText: 'Search bookings...',
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
                      ...BookingModel.statuses.map((status) => 
                        DropdownMenuItem(
                          value: status, 
                          child: Text(BookingModel.getStatusDisplayName(status)),
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
                  text: 'Add Booking',
                  onPressed: () => _showBookingDialog(context, controller),
                  icon: Icons.add,
                ),
              ],
            ),
          ),
          
          // Bookings List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.bookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64.sp,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No bookings found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Create your first booking to get started',
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
                onRefresh: () => controller.loadBookings(refresh: true),
                child: ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = controller.filteredBookings[index];
                    return _buildBookingCard(booking, controller, context);
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
                color: color.withOpacity(0.1),
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
  
  Widget _buildBookingCard(BookingModel booking, BookingController controller, BuildContext context) {
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
                        booking.customerName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Restaurant ID: ${booking.restId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                _buildStatusBadge(booking.status),
                
                SizedBox(width: 16.w),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        controller.loadBookingForEdit(booking);
                        _showBookingDialog(context, controller);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      tooltip: 'Edit Booking',
                    ),
                    if (booking.canBeConfirmed) ...[
                      IconButton(
                        onPressed: () => controller.updateBookingStatus(booking, 'confirmed'),
                        icon: Icon(
                          Icons.check,
                          color: AppColors.success,
                          size: 20.sp,
                        ),
                        tooltip: 'Confirm Booking',
                      ),
                    ],
                    if (booking.canBeCancelled) ...[
                      IconButton(
                        onPressed: () => _showCancelDialog(context, controller, booking),
                        icon: Icon(
                          Icons.cancel,
                          color: AppColors.warning,
                          size: 20.sp,
                        ),
                        tooltip: 'Cancel Booking',
                      ),
                    ],
                    if (booking.canBeCompleted) ...[
                      IconButton(
                        onPressed: () => controller.updateBookingStatus(booking, 'completed'),
                        icon: Icon(
                          Icons.done_all,
                          color: AppColors.info,
                          size: 20.sp,
                        ),
                        tooltip: 'Mark Completed',
                      ),
                    ],
                    if (booking.canBeMarkedNoShow) ...[
                      IconButton(
                        onPressed: () => controller.updateBookingStatus(booking, 'no_show'),
                        icon: Icon(
                          Icons.person_off,
                          color: AppColors.error,
                          size: 20.sp,
                        ),
                        tooltip: 'Mark No Show',
                      ),
                    ],
                    IconButton(
                      onPressed: () => _showDeleteDialog(context, controller, booking),
                      icon: Icon(
                        Icons.delete,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      tooltip: 'Delete Booking',
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Booking Details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Date', DateFormat('MMM dd, yyyy').format(booking.bookingDate)),
                ),
                Expanded(
                  child: _buildInfoItem('Time', booking.bookingTime),
                ),
                Expanded(
                  child: _buildInfoItem('Guests', booking.numberOfGuests.toString()),
                ),
                Expanded(
                  child: _buildInfoItem('Status', BookingModel.getStatusDisplayName(booking.status)),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Contact Information
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Email', booking.customerEmail),
                ),
                Expanded(
                  child: _buildInfoItem('Phone', booking.customerMobile),
                ),
                Expanded(
                  child: _buildInfoItem('Created', DateFormat('MMM dd, yyyy').format(booking.createdAt)),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            
            // Special Requests if available
            if (booking.specialRequests.isNotEmpty) ...[
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
                      'Special Requests:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      booking.specialRequests,
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
      case 'confirmed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      case 'completed':
        color = AppColors.info;
        break;
      case 'no_show':
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
        BookingModel.getStatusDisplayName(status),
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

  void _showBookingDialog(BuildContext context, BookingController controller) {
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
                      controller.currentBooking.value != null ? 'Edit Booking' : 'Create New Booking',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Customer Information
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.customerNameController,
                            label: 'Customer Name',
                            hintText: 'Enter customer name',
                            validator: (value) => controller.validateRequired(value, 'Customer name'),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CustomTextField(
                            controller: controller.customerEmailController,
                            label: 'Email',
                            hintText: 'Enter email address',
                            validator: (value) => controller.validateEmail(value),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

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
                          child: CustomTextField(
                            controller: controller.numberOfGuestsController,
                            label: 'Number of Guests',
                            hintText: 'Enter number of guests',
                            keyboardType: TextInputType.number,
                            validator: (value) => controller.validatePositiveNumber(value, 'Number of guests'),
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
                          text: controller.currentBooking.value != null ? 'Update Booking' : 'Create Booking',
                          onPressed: controller.isLoading.value ? null : () async {
                            await controller.saveBooking();
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

  void _showCancelDialog(BuildContext context, BookingController controller, BookingModel booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking for ${booking.customerName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                controller.updateBookingStatus(booking, 'cancelled');
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel Booking',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, BookingController controller, BookingModel booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: Text('Are you sure you want to delete this booking for ${booking.customerName}?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteBooking(booking);
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
