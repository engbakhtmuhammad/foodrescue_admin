import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/surprise_bag_order_model.dart';
import '../utils/app_utils.dart';

class SurpriseBagOrderController extends GetxController {
  static SurpriseBagOrderController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final orders = <SurpriseBagOrderModel>[].obs;
  final filteredOrders = <SurpriseBagOrderModel>[].obs;
  final currentOrder = Rx<SurpriseBagOrderModel?>(null);
  
  // Current restaurant ID (set when restaurant owner logs in)
  final currentRestaurantId = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedDateFilter = 'all'.obs; // 'all', 'today', 'tomorrow', 'this_week'
  final selectedPaymentStatusFilter = 'all'.obs;
  
  // Form controllers for restaurant notes
  final restaurantNotesController = TextEditingController();
  final cancellationReasonController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    _initializeRestaurantId();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterOrders();
    });
  }
  
  @override
  void onClose() {
    searchController.dispose();
    restaurantNotesController.dispose();
    cancellationReasonController.dispose();
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
        loadOrders();
      }
    } catch (e) {
      print('Error finding restaurant: $e');
    }
  }
  
  // Load orders for current restaurant
  Future<void> loadOrders({bool refresh = false}) async {
    if (currentRestaurantId.value.isEmpty) {
      return;
    }
    
    if (refresh) {
      orders.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.surpriseBagOrdersCollection,
        filters: [QueryFilter(field: 'restaurantId', value: currentRestaurantId.value)],
        orderBy: 'orderDate',
        descending: true,
      );
      
      if (query != null) {
        orders.value = query.docs
            .map((doc) => SurpriseBagOrderModel.fromFirestore(doc))
            .toList();
      }
      
      _filterOrders();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter orders
  void _filterOrders() {
    var filtered = orders.where((order) {
      final matchesSearch = searchQuery.value.isEmpty ||
          order.userName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          order.userEmail.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          order.userPhone.contains(searchQuery.value) ||
          order.surpriseBagTitle.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          order.status == selectedStatusFilter.value;
      
      final matchesPaymentStatus = selectedPaymentStatusFilter.value == 'all' ||
          order.paymentStatus == selectedPaymentStatusFilter.value;
      
      final matchesDate = _matchesDateFilter(order);
      
      return matchesSearch && matchesStatus && matchesPaymentStatus && matchesDate;
    }).toList();
    
    filteredOrders.value = filtered;
  }
  
  // Check if order matches date filter
  bool _matchesDateFilter(SurpriseBagOrderModel order) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final pickupDate = DateTime(
      order.pickupDate.year,
      order.pickupDate.month,
      order.pickupDate.day,
    );
    
    switch (selectedDateFilter.value) {
      case 'today':
        return pickupDate.isAtSameMomentAs(today);
      case 'tomorrow':
        return pickupDate.isAtSameMomentAs(tomorrow);
      case 'this_week':
        return pickupDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               pickupDate.isBefore(weekEnd.add(const Duration(days: 1)));
      default:
        return true;
    }
  }
  
  // Update order status
  Future<void> updateOrderStatus(SurpriseBagOrderModel order, String newStatus, {String? notes}) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      // Add status-specific timestamps and data
      switch (newStatus) {
        case 'confirmed':
          if (order.status != 'confirmed') {
            updateData['confirmedAt'] = Timestamp.fromDate(now);
          }
          break;
        case 'ready':
          if (order.status != 'ready') {
            updateData['readyAt'] = Timestamp.fromDate(now);
          }
          break;
        case 'completed':
          if (order.status != 'completed') {
            updateData['completedAt'] = Timestamp.fromDate(now);
          }
          break;
        case 'cancelled':
          if (order.status != 'cancelled') {
            updateData['cancelledAt'] = Timestamp.fromDate(now);
            if (notes != null && notes.isNotEmpty) {
              updateData['cancellationReason'] = notes;
            }
          }
          break;
      }
      
      // Add restaurant notes if provided
      if (notes != null && notes.isNotEmpty && newStatus != 'cancelled') {
        updateData['restaurantNotes'] = notes;
      }
      
      await _firestoreService.updateDocument(
        collection: AppConstants.surpriseBagOrdersCollection,
        docId: order.id,
        data: updateData,
      );
      
      AppUtils.showSuccessSnackbar('Order status updated successfully');
      await loadOrders(refresh: true);
      
      // Send notification to customer (you can implement this)
      await _sendNotificationToCustomer(order, newStatus);
      
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update order status: $e');
    }
  }
  
  // Set filters
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterOrders();
  }
  
  void setDateFilter(String dateFilter) {
    selectedDateFilter.value = dateFilter;
    _filterOrders();
  }
  
  void setPaymentStatusFilter(String paymentStatus) {
    selectedPaymentStatusFilter.value = paymentStatus;
    _filterOrders();
  }
  
  // Get orders count by status
  int getOrdersCountByStatus(String status) {
    return orders.where((order) => order.status == status).length;
  }
  
  // Get today's orders
  List<SurpriseBagOrderModel> getTodaysOrders() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return orders.where((order) {
      return order.pickupDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
             order.pickupDate.isBefore(todayEnd);
    }).toList();
  }
  
  // Get pending orders (need confirmation)
  List<SurpriseBagOrderModel> getPendingOrders() {
    return orders.where((order) => order.status == 'pending' && order.isPaid).toList();
  }
  
  // Get ready orders (ready for pickup)
  List<SurpriseBagOrderModel> getReadyOrders() {
    return orders.where((order) => order.status == 'ready').toList();
  }
  
  // Calculate total revenue
  double getTotalRevenue() {
    return orders
        .where((order) => order.isCompleted)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }
  
  // Calculate today's revenue
  double getTodaysRevenue() {
    final todaysOrders = getTodaysOrders();
    return todaysOrders
        .where((order) => order.isCompleted)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }
  
  // Send notification to customer (placeholder for future implementation)
  Future<void> _sendNotificationToCustomer(SurpriseBagOrderModel order, String newStatus) async {
    try {
      String title = '';
      String message = '';

      switch (newStatus) {
        case 'confirmed':
          title = 'Order Confirmed!';
          message = 'Your order for ${order.surpriseBagTitle} from ${order.restaurantName} has been confirmed.';
          break;
        case 'ready':
          title = 'Order Ready for Pickup!';
          message = 'Your ${order.surpriseBagTitle} from ${order.restaurantName} is ready for pickup.';
          break;
        case 'completed':
          title = 'Order Completed';
          message = 'Thank you for picking up your ${order.surpriseBagTitle} from ${order.restaurantName}!';
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          message = 'Your order for ${order.surpriseBagTitle} from ${order.restaurantName} has been cancelled.';
          break;
      }

      // Save notification to database
      await _firestoreService.createDocument(
        collection: 'notifications',
        data: {
          'userId': order.userId,
          'title': title,
          'message': message,
          'type': 'order_status',
          'data': {
            'orderId': order.id,
            'status': newStatus,
            'restaurantName': order.restaurantName,
            'bagTitle': order.surpriseBagTitle,
          },
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      print('Notification sent to ${order.userEmail}: $message');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  
  // Clear form controllers
  void clearForm() {
    restaurantNotesController.clear();
    cancellationReasonController.clear();
  }
}
