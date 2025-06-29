import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../utils/app_utils.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final users = <UserModel>[].obs;
  final filteredUsers = <UserModel>[].obs;
  
  // Statistics
  final totalUsers = 0.obs;
  final activeUsers = 0.obs;
  final adminUsers = 0.obs;
  final restaurantOwners = 0.obs;
  final customerUsers = 0.obs;
  
  // Pagination
  final currentPage = 0.obs;
  final hasMoreData = true.obs;
  DocumentSnapshot? lastDocument;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedRoleFilter = 'all'.obs;
  final selectedStatusFilter = 'all'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadUserStatistics();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterUsers();
    });
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  
  // Load users
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      lastDocument = null;
      hasMoreData.value = true;
      users.clear();
    }
    
    if (!hasMoreData.value) return;
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.usersCollection,
        limit: AppConstants.itemsPerPage,
        startAfter: lastDocument,
        orderBy: 'createdAt',
        descending: true,
      );
      
      if (query != null && query.docs.isNotEmpty) {
        final newUsers = query.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
        
        if (refresh) {
          users.value = newUsers;
        } else {
          users.addAll(newUsers);
        }
        
        lastDocument = query.docs.last;
        hasMoreData.value = query.docs.length == AppConstants.itemsPerPage;
        currentPage.value++;
      } else {
        hasMoreData.value = false;
      }
      
      _filterUsers();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load user statistics
  Future<void> loadUserStatistics() async {
    try {
      // Total users
      final total = await _firestoreService.getDocumentCount(
        collection: AppConstants.usersCollection,
      );
      totalUsers.value = total;
      
      // Active users
      final active = await _firestoreService.getDocumentCount(
        collection: AppConstants.usersCollection,
        filters: [QueryFilter(field: 'isActive', value: true)],
      );
      activeUsers.value = active;
      
      // Admin users
      final admins = await _firestoreService.getDocumentCount(
        collection: AppConstants.usersCollection,
        filters: [QueryFilter(field: 'role', value: AppConstants.adminRole)],
      );
      adminUsers.value = admins;
      
      // Restaurant owners
      final owners = await _firestoreService.getDocumentCount(
        collection: AppConstants.usersCollection,
        filters: [QueryFilter(field: 'role', value: AppConstants.restaurantOwnerRole)],
      );
      restaurantOwners.value = owners;
      
      // Customer users
      final customers = await _firestoreService.getDocumentCount(
        collection: AppConstants.usersCollection,
        filters: [QueryFilter(field: 'role', value: 'customer')],
      );
      customerUsers.value = customers;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load user statistics: $e');
    }
  }
  
  // Filter users
  void _filterUsers() {
    var filtered = users.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((user) =>
          user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (user.mobile?.contains(searchQuery.value) ?? false)
      ).toList();
    }
    
    // Apply role filter
    if (selectedRoleFilter.value != 'all') {
      filtered = filtered.where((user) =>
          user.role == selectedRoleFilter.value
      ).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      final isActive = selectedStatusFilter.value == 'active';
      filtered = filtered.where((user) =>
          user.isActive == isActive
      ).toList();
    }
    
    filteredUsers.value = filtered;
  }
  
  // Set role filter
  void setRoleFilter(String role) {
    selectedRoleFilter.value = role;
    _filterUsers();
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterUsers();
  }
  
  // Toggle user status
  Future<void> toggleUserStatus(UserModel user) async {
    final newStatus = !user.isActive;
    final action = newStatus ? 'activate' : 'deactivate';
    
    final confirmed = await AppUtils.showConfirmationDialog(
      title: '${AppUtils.capitalizeFirst(action)} User',
      message: 'Are you sure you want to $action "${user.name}"?',
      confirmText: AppUtils.capitalizeFirst(action),
    );
    
    if (!confirmed) return;
    
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.usersCollection,
        docId: user.id,
        data: {
          'isActive': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('User ${action}d successfully');
      await loadUsers(refresh: true);
      await loadUserStatistics();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to $action user: $e');
    }
  }
  
  // Delete user (if needed)
  Future<void> deleteUser(UserModel user) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete User',
      message: 'Are you sure you want to delete "${user.name}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.usersCollection,
        docId: user.id,
      );
      
      AppUtils.showSuccessSnackbar('User deleted successfully');
      await loadUsers(refresh: true);
      await loadUserStatistics();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete user: $e');
    }
  }
  
  // Export users (placeholder for future implementation)
  Future<void> exportUsers() async {
    AppUtils.showInfoSnackbar('Export functionality will be implemented soon');
  }
  
  // Refresh users
  Future<void> refreshUsers() async {
    await loadUsers(refresh: true);
    await loadUserStatistics();
  }
  
  // Get role display name
  String getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.adminRole:
        return 'Admin';
      case AppConstants.restaurantOwnerRole:
        return 'Restaurant Owner';
      case 'customer':
        return 'Customer';
      default:
        return AppUtils.capitalizeFirst(role);
    }
  }
  
  // Get role color
  Color getRoleColor(String role) {
    switch (role) {
      case AppConstants.adminRole:
        return Colors.red;
      case AppConstants.restaurantOwnerRole:
        return Colors.orange;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
