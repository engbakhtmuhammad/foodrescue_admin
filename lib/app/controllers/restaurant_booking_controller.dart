import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../utils/app_utils.dart';

class RestaurantBookingController extends GetxController {
  static RestaurantBookingController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final bookings = <BookingModel>[].obs;
  final filteredBookings = <BookingModel>[].obs;
  final currentBooking = Rx<BookingModel?>(null);
  
  // Current restaurant ID (set when restaurant owner logs in)
  final currentRestaurantId = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedDateFilter = 'all'.obs; // 'all', 'today', 'tomorrow', 'this_week'
  
  @override
  void onInit() {
    super.onInit();
    _initializeRestaurantId();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterBookings();
    });
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Initialize restaurant ID from current user
  void _initializeRestaurantId() {
    final currentUser = _authService.currentUser.value;
    if (currentUser != null && currentUser.role == 'restaurant_owner') {
      // For restaurant owners, find their restaurant
      _findRestaurantByOwnerId(currentUser.id);
    }
  }
  
  // Find restaurant by owner ID
  Future<void> _findRestaurantByOwnerId(String ownerId) async {
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.restaurantsCollection,
        filters: [QueryFilter(field: 'ownerId', value: ownerId)],
        limit: 1,
      );
      
      if (query != null && query.docs.isNotEmpty) {
        currentRestaurantId.value = query.docs.first.id;
        loadBookings();
      }
    } catch (e) {
      print('Error finding restaurant: $e');
    }
  }
  
  // Load bookings for current restaurant
  Future<void> loadBookings({bool refresh = false}) async {
    if (currentRestaurantId.value.isEmpty) {
      return;
    }
    
    if (refresh) {
      bookings.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.bookingsCollection,
        filters: [QueryFilter(field: 'restId', value: currentRestaurantId.value)],
        orderBy: 'bookingDate',
        descending: true,
      );
      
      if (query != null) {
        bookings.value = query.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList();
      }
      
      _filterBookings();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter bookings
  void _filterBookings() {
    var filtered = bookings.where((booking) {
      final matchesSearch = searchQuery.value.isEmpty ||
          booking.customerName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          booking.customerEmail.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          booking.customerMobile.contains(searchQuery.value);
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          booking.status == selectedStatusFilter.value;
      
      final matchesDate = _matchesDateFilter(booking);
      
      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
    
    filteredBookings.value = filtered;
  }
  
  // Check if booking matches date filter
  bool _matchesDateFilter(BookingModel booking) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final bookingDate = DateTime(
      booking.bookingDate.year,
      booking.bookingDate.month,
      booking.bookingDate.day,
    );
    
    switch (selectedDateFilter.value) {
      case 'today':
        return bookingDate.isAtSameMomentAs(today);
      case 'tomorrow':
        return bookingDate.isAtSameMomentAs(tomorrow);
      case 'this_week':
        return bookingDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               bookingDate.isBefore(weekEnd.add(const Duration(days: 1)));
      default:
        return true;
    }
  }
  
  // Update booking status
  Future<void> updateBookingStatus(BookingModel booking, String newStatus) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      // Add status-specific timestamps
      switch (newStatus) {
        case 'confirmed':
          if (booking.status != 'confirmed') {
            updateData['confirmedAt'] = Timestamp.fromDate(now);
          }
          break;
        case 'cancelled':
          if (booking.status != 'cancelled') {
            updateData['cancelledAt'] = Timestamp.fromDate(now);
          }
          break;
      }
      
      await _firestoreService.updateDocument(
        collection: AppConstants.bookingsCollection,
        docId: booking.id,
        data: updateData,
      );
      
      AppUtils.showSuccessSnackbar('Booking status updated successfully');
      await loadBookings(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update booking status: $e');
    }
  }
  
  // Set filters
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterBookings();
  }
  
  void setDateFilter(String dateFilter) {
    selectedDateFilter.value = dateFilter;
    _filterBookings();
  }
  
  // Get bookings count by status
  int getBookingsCountByStatus(String status) {
    return bookings.where((booking) => booking.status == status).length;
  }
  
  // Get today's bookings
  List<BookingModel> getTodaysBookings() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return bookings.where((booking) {
      return booking.bookingDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
             booking.bookingDate.isBefore(todayEnd);
    }).toList();
  }
  
  // Get upcoming bookings (next 7 days)
  List<BookingModel> getUpcomingBookings() {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return bookings.where((booking) {
      return booking.bookingDate.isAfter(now) &&
             booking.bookingDate.isBefore(weekFromNow) &&
             (booking.status == 'pending' || booking.status == 'confirmed');
    }).toList();
  }
  
  // Send notification to customer (placeholder for future implementation)
  Future<void> sendNotificationToCustomer(BookingModel booking, String message) async {
    // TODO: Implement push notification or email notification
    print('Sending notification to ${booking.customerEmail}: $message');
  }
}
