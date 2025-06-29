import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../models/restaurant_model.dart';
import '../utils/app_utils.dart';

class BookingController extends GetxController {
  static BookingController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final bookings = <BookingModel>[].obs;
  final filteredBookings = <BookingModel>[].obs;
  final restaurants = <RestaurantModel>[].obs;
  final currentBooking = Rx<BookingModel?>(null);
  
  // Form controllers
  final customerNameController = TextEditingController();
  final customerEmailController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final numberOfGuestsController = TextEditingController();
  final specialRequestsController = TextEditingController();
  final cancelReasonController = TextEditingController();

  // Form variables
  final selectedRestaurantId = ''.obs;
  final selectedBookingDate = Rx<DateTime?>(null);
  final selectedTimeSlot = ''.obs;
  final selectedStatus = 'pending'.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedRestaurantFilter = 'all'.obs;
  final selectedDateFilter = 'all'.obs; // 'all', 'today', 'tomorrow', 'this_week'
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadBookings();
    loadRestaurants();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterBookings();
    });
  }
  
  @override
  void onClose() {
    customerNameController.dispose();
    customerEmailController.dispose();
    customerPhoneController.dispose();
    numberOfGuestsController.dispose();
    specialRequestsController.dispose();
    cancelReasonController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load bookings
  Future<void> loadBookings({bool refresh = false}) async {
    if (refresh) {
      bookings.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.bookingsCollection,
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
  
  // Load restaurants
  Future<void> loadRestaurants() async {
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.restaurantsCollection,
        orderBy: 'title',
        descending: false,
      );
      
      if (query != null) {
        restaurants.value = query.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load restaurants: $e');
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

      final matchesRestaurant = selectedRestaurantFilter.value == 'all' ||
          booking.restId == selectedRestaurantFilter.value;
      
      final matchesDate = _matchesDateFilter(booking);
      
      return matchesSearch && matchesStatus && matchesRestaurant && matchesDate;
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
  
  // Clear form
  void clearForm() {
    customerNameController.clear();
    customerEmailController.clear();
    customerPhoneController.clear();
    numberOfGuestsController.clear();
    specialRequestsController.clear();
    cancelReasonController.clear();
    selectedRestaurantId.value = '';
    selectedBookingDate.value = null;
    selectedTimeSlot.value = '';
    selectedStatus.value = 'pending';
    currentBooking.value = null;
  }

  // Load booking for editing
  void loadBookingForEdit(BookingModel booking) {
    currentBooking.value = booking;
    customerNameController.text = booking.customerName;
    customerEmailController.text = booking.customerEmail;
    customerPhoneController.text = booking.customerMobile;
    numberOfGuestsController.text = booking.numberOfGuests.toString();
    specialRequestsController.text = booking.specialRequests;
    selectedRestaurantId.value = booking.restId;
    selectedBookingDate.value = booking.bookingDate;
    selectedTimeSlot.value = booking.bookingTime;
    selectedStatus.value = booking.status;
  }
  
  // Save booking
  Future<void> saveBooking() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedRestaurantId.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a restaurant');
      return;
    }
    
    if (selectedBookingDate.value == null) {
      AppUtils.showErrorSnackbar('Please select a booking date');
      return;
    }
    
    if (selectedTimeSlot.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a time slot');
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Find selected restaurant
      final restaurant = restaurants.firstWhereOrNull(
        (r) => r.id == selectedRestaurantId.value,
      );
      
      if (restaurant == null) {
        AppUtils.showErrorSnackbar('Restaurant not found');
        return;
      }
      
      final now = DateTime.now();
      
      final bookingData = {
        'uid': '', // Will be set when customer books
        'customerName': customerNameController.text.trim(),
        'customerEmail': customerEmailController.text.trim(),
        'customerMobile': customerPhoneController.text.trim(),
        'restId': selectedRestaurantId.value,
        'bookingDate': Timestamp.fromDate(selectedBookingDate.value!),
        'bookingTime': selectedTimeSlot.value,
        'numberOfGuests': int.tryParse(numberOfGuestsController.text) ?? 1,
        'status': selectedStatus.value,
        'specialRequests': specialRequestsController.text.trim(),
        'updatedAt': Timestamp.fromDate(now),
      };
      
      String? bookingId;
      
      if (currentBooking.value != null) {
        // Update existing booking
        bookingId = currentBooking.value!.id;
        
        // Add status-specific timestamps
        if (selectedStatus.value == 'confirmed' && currentBooking.value!.status != 'confirmed') {
          bookingData['confirmedAt'] = Timestamp.fromDate(now);
        } else if (selectedStatus.value == 'cancelled' && currentBooking.value!.status != 'cancelled') {
          bookingData['cancelledAt'] = Timestamp.fromDate(now);
          if (cancelReasonController.text.trim().isNotEmpty) {
            bookingData['cancelReason'] = cancelReasonController.text.trim();
          }
        }
        
        await _firestoreService.updateDocument(
          collection: AppConstants.bookingsCollection,
          docId: bookingId,
          data: bookingData,
        );
        AppUtils.showSuccessSnackbar('Booking updated successfully');
      } else {
        // Create new booking
        bookingData['createdAt'] = Timestamp.fromDate(now);
        bookingId = await _firestoreService.createDocument(
          collection: AppConstants.bookingsCollection,
          data: bookingData,
        );
        AppUtils.showSuccessSnackbar('Booking created successfully');
      }
      
      if (bookingId != null) {
        await loadBookings(refresh: true);
        clearForm();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save booking: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete booking
  Future<void> deleteBooking(BookingModel booking) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.bookingsCollection,
        docId: booking.id,
      );

      AppUtils.showSuccessSnackbar('Booking deleted successfully');
      await loadBookings(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete booking: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(BookingModel booking, String newStatus, {String? reason}) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(now),
      };

      // Add status-specific timestamps and data
      switch (newStatus) {
        case 'confirmed':
          if (booking.status != 'confirmed') {
            updateData['confirmedAt'] = Timestamp.fromDate(now);
          }
          break;
        case 'cancelled':
          if (booking.status != 'cancelled') {
            updateData['cancelledAt'] = Timestamp.fromDate(now);
            if (reason?.isNotEmpty == true) {
              updateData['cancelReason'] = reason;
            }
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

  void setRestaurantFilter(String restaurantId) {
    selectedRestaurantFilter.value = restaurantId;
    _filterBookings();
  }

  void setDateFilter(String dateFilter) {
    selectedDateFilter.value = dateFilter;
    _filterBookings();
  }

  // Date picker helpers
  Future<void> selectBookingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBookingDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedBookingDate.value = picked;
    }
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

  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
}
