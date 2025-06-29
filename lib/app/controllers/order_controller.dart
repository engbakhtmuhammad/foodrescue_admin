import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../utils/app_utils.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final orders = <OrderModel>[].obs;
  final filteredOrders = <OrderModel>[].obs;
  final currentOrder = Rx<OrderModel?>(null);
  final orderUsers = <String, UserModel>{}.obs;
  final orderRestaurants = <String, RestaurantModel>{}.obs;
  
  // Pagination
  final currentPage = 0.obs;
  final hasMoreData = true.obs;
  DocumentSnapshot? lastDocument;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedDateRange = Rx<DateTimeRange?>(null);
  
  // Statistics
  final totalOrders = 0.obs;
  final totalEarnings = 0.0.obs;
  final pendingOrders = 0.obs;
  final confirmedOrders = 0.obs;
  final completedOrders = 0.obs;
  final cancelledOrders = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadOrderStatistics();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterOrders();
    });
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Load orders
  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      lastDocument = null;
      hasMoreData.value = true;
      orders.clear();
      orderUsers.clear();
      orderRestaurants.clear();
    }
    
    if (!hasMoreData.value) return;
    
    isLoading.value = true;
    
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurant's orders
      if (_authService.isRestaurantOwner) {
        final currentUser = _authService.currentUser.value;
        if (currentUser != null) {
          // First get the restaurant owned by this user
          final restaurantQuery = await _firestoreService.getCollection(
            collection: AppConstants.restaurantsCollection,
            filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
            limit: 1,
          );
          
          if (restaurantQuery?.docs.isNotEmpty == true) {
            final restaurantId = restaurantQuery!.docs.first.id;
            filters = [QueryFilter(field: 'restId', value: restaurantId)];
          } else {
            // No restaurant found for this owner
            isLoading.value = false;
            return;
          }
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.ordersCollection,
        limit: AppConstants.itemsPerPage,
        startAfter: lastDocument,
        orderBy: 'createdAt',
        descending: true,
        filters: filters,
      );
      
      if (query != null && query.docs.isNotEmpty) {
        final newOrders = query.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();
        
        if (refresh) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }
        
        // Load related user and restaurant data
        await _loadRelatedData(newOrders);
        
        lastDocument = query.docs.last;
        hasMoreData.value = query.docs.length == AppConstants.itemsPerPage;
        currentPage.value++;
      } else {
        hasMoreData.value = false;
      }
      
      _filterOrders();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load related user and restaurant data
  Future<void> _loadRelatedData(List<OrderModel> ordersList) async {
    final userIds = ordersList.map((order) => order.uid).toSet();
    final restaurantIds = ordersList.map((order) => order.restId).toSet();
    
    // Load users
    for (final userId in userIds) {
      if (!orderUsers.containsKey(userId)) {
        final userDoc = await _firestoreService.getDocument(
          collection: AppConstants.usersCollection,
          docId: userId,
        );
        if (userDoc != null && userDoc.exists) {
          orderUsers[userId] = UserModel.fromFirestore(userDoc);
        }
      }
    }
    
    // Load restaurants
    for (final restaurantId in restaurantIds) {
      if (!orderRestaurants.containsKey(restaurantId)) {
        final restaurantDoc = await _firestoreService.getDocument(
          collection: AppConstants.restaurantsCollection,
          docId: restaurantId,
        );
        if (restaurantDoc != null && restaurantDoc.exists) {
          orderRestaurants[restaurantId] = RestaurantModel.fromFirestore(restaurantDoc);
        }
      }
    }
  }
  
  // Load order statistics
  Future<void> loadOrderStatistics() async {
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurant's statistics
      if (_authService.isRestaurantOwner) {
        final currentUser = _authService.currentUser.value;
        if (currentUser != null) {
          final restaurantQuery = await _firestoreService.getCollection(
            collection: AppConstants.restaurantsCollection,
            filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
            limit: 1,
          );
          
          if (restaurantQuery?.docs.isNotEmpty == true) {
            final restaurantId = restaurantQuery!.docs.first.id;
            filters = [QueryFilter(field: 'restId', value: restaurantId)];
          }
        }
      }
      
      // Total orders
      final totalCount = await _firestoreService.getDocumentCount(
        collection: AppConstants.ordersCollection,
        filters: filters,
      );
      totalOrders.value = totalCount;
      
      // Total earnings
      final earningsData = await _firestoreService.getAggregatedData(
        collection: AppConstants.ordersCollection,
        field: 'payedAmount',
        type: AggregationType.sum,
        filters: filters,
      );
      if (earningsData != null) {
        totalEarnings.value = earningsData['result'] ?? 0.0;
      }
      
      // Status counts
      final statusCounts = await Future.wait([
        _firestoreService.getDocumentCount(
          collection: AppConstants.ordersCollection,
          filters: [
            ...?filters,
            QueryFilter(field: 'status', value: AppConstants.orderPending),
          ],
        ),
        _firestoreService.getDocumentCount(
          collection: AppConstants.ordersCollection,
          filters: [
            ...?filters,
            QueryFilter(field: 'status', value: AppConstants.orderConfirmed),
          ],
        ),
        _firestoreService.getDocumentCount(
          collection: AppConstants.ordersCollection,
          filters: [
            ...?filters,
            QueryFilter(field: 'status', value: AppConstants.orderCompleted),
          ],
        ),
        _firestoreService.getDocumentCount(
          collection: AppConstants.ordersCollection,
          filters: [
            ...?filters,
            QueryFilter(field: 'status', value: AppConstants.orderCancelled),
          ],
        ),
      ]);
      
      pendingOrders.value = statusCounts[0];
      confirmedOrders.value = statusCounts[1];
      completedOrders.value = statusCounts[2];
      cancelledOrders.value = statusCounts[3];
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load order statistics: $e');
    }
  }
  
  // Filter orders
  void _filterOrders() {
    var filtered = orders.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((order) {
        final user = orderUsers[order.uid];
        final restaurant = orderRestaurants[order.restId];
        
        return order.id.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user?.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            (user?.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
            (restaurant?.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      }).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      filtered = filtered.where((order) =>
          order.status == selectedStatusFilter.value
      ).toList();
    }
    
    // Apply date range filter
    if (selectedDateRange.value != null) {
      final startDate = selectedDateRange.value!.start;
      final endDate = selectedDateRange.value!.end.add(const Duration(days: 1));
      
      filtered = filtered.where((order) =>
          order.orderDate.isAfter(startDate) && order.orderDate.isBefore(endDate)
      ).toList();
    }
    
    filteredOrders.value = filtered;
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterOrders();
  }
  
  // Set date range filter
  void setDateRangeFilter(DateTimeRange? dateRange) {
    selectedDateRange.value = dateRange;
    _filterOrders();
  }
  
  // Update order status
  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.ordersCollection,
        docId: order.id,
        data: {
          'status': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Order status updated successfully');
      await loadOrders(refresh: true);
      await loadOrderStatistics();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update order status: $e');
    }
  }
  
  // Get order details
  Future<void> getOrderDetails(String orderId) async {
    try {
      final orderDoc = await _firestoreService.getDocument(
        collection: AppConstants.ordersCollection,
        docId: orderId,
      );
      
      if (orderDoc != null && orderDoc.exists) {
        currentOrder.value = OrderModel.fromFirestore(orderDoc);
        
        // Load related data for this order
        await _loadRelatedData([currentOrder.value!]);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load order details: $e');
    }
  }
  
  // Get user for order
  UserModel? getUserForOrder(String userId) {
    return orderUsers[userId];
  }
  
  // Get restaurant for order
  RestaurantModel? getRestaurantForOrder(String restaurantId) {
    return orderRestaurants[restaurantId];
  }
  
  // Get status color
  Color getStatusColor(String status) {
    return AppUtils.getStatusColor(status);
  }
  
  // Get status display name
  String getStatusDisplayName(String status) {
    switch (status) {
      case AppConstants.orderPending:
        return 'Pending';
      case AppConstants.orderConfirmed:
        return 'Confirmed';
      case AppConstants.orderCompleted:
        return 'Completed';
      case AppConstants.orderCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
  
  // Get available status options for update
  List<String> getAvailableStatusOptions(String currentStatus) {
    switch (currentStatus) {
      case AppConstants.orderPending:
        return [AppConstants.orderConfirmed, AppConstants.orderCancelled];
      case AppConstants.orderConfirmed:
        return [AppConstants.orderCompleted, AppConstants.orderCancelled];
      case AppConstants.orderCompleted:
        return []; // No status change allowed
      case AppConstants.orderCancelled:
        return []; // No status change allowed
      default:
        return [];
    }
  }
  
  // Export orders (placeholder for future implementation)
  Future<void> exportOrders() async {
    AppUtils.showInfoSnackbar('Export functionality will be implemented soon');
  }
  
  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
    await loadOrderStatistics();
  }
}
