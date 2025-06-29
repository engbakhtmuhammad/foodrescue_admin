import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/payout_model.dart';
import '../models/restaurant_model.dart';
import '../utils/app_utils.dart';

class PayoutController extends GetxController {
  static PayoutController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final payouts = <PayoutModel>[].obs;
  final filteredPayouts = <PayoutModel>[].obs;
  final restaurants = <RestaurantModel>[].obs;
  final currentPayout = Rx<PayoutModel?>(null);
  
  // Form controllers
  final amountController = TextEditingController();
  final commissionController = TextEditingController();
  final transactionIdController = TextEditingController();
  final bankAccountController = TextEditingController();
  final paypalEmailController = TextEditingController();
  final notesController = TextEditingController();
  final failureReasonController = TextEditingController();
  
  // Form variables
  final selectedRestaurantId = ''.obs;
  final selectedStatus = 'pending'.obs;
  final selectedPaymentMethod = 'bank_transfer'.obs;
  final selectedPeriodStart = Rx<DateTime?>(null);
  final selectedPeriodEnd = Rx<DateTime?>(null);
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedPaymentMethodFilter = 'all'.obs;
  final selectedRestaurantFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadPayouts();
    loadRestaurants();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterPayouts();
    });
  }
  
  @override
  void onClose() {
    amountController.dispose();
    commissionController.dispose();
    transactionIdController.dispose();
    bankAccountController.dispose();
    paypalEmailController.dispose();
    notesController.dispose();
    failureReasonController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load payouts
  Future<void> loadPayouts({bool refresh = false}) async {
    if (refresh) {
      payouts.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.payoutsCollection,
        orderBy: 'requestedAt',
        descending: true,
      );
      
      if (query != null) {
        payouts.value = query.docs
            .map((doc) => PayoutModel.fromFirestore(doc))
            .toList();
      }
      
      _filterPayouts();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load payouts: $e');
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
  
  // Filter payouts
  void _filterPayouts() {
    var filtered = payouts.where((payout) {
      final matchesSearch = searchQuery.value.isEmpty ||
          payout.restaurantName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          payout.restaurantOwnerEmail.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (payout.transactionId?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          payout.status == selectedStatusFilter.value;
      
      final matchesPaymentMethod = selectedPaymentMethodFilter.value == 'all' ||
          payout.paymentMethod == selectedPaymentMethodFilter.value;
      
      final matchesRestaurant = selectedRestaurantFilter.value == 'all' ||
          payout.restaurantId == selectedRestaurantFilter.value;
      
      return matchesSearch && matchesStatus && matchesPaymentMethod && matchesRestaurant;
    }).toList();
    
    filteredPayouts.value = filtered;
  }
  
  // Clear form
  void clearForm() {
    amountController.clear();
    commissionController.clear();
    transactionIdController.clear();
    bankAccountController.clear();
    paypalEmailController.clear();
    notesController.clear();
    failureReasonController.clear();
    selectedRestaurantId.value = '';
    selectedStatus.value = 'pending';
    selectedPaymentMethod.value = 'bank_transfer';
    selectedPeriodStart.value = null;
    selectedPeriodEnd.value = null;
    currentPayout.value = null;
  }
  
  // Load payout for editing
  void loadPayoutForEdit(PayoutModel payout) {
    currentPayout.value = payout;
    selectedRestaurantId.value = payout.restaurantId;
    amountController.text = payout.amount.toString();
    commissionController.text = payout.commissionAmount.toString();
    transactionIdController.text = payout.transactionId ?? '';
    bankAccountController.text = payout.bankAccountDetails ?? '';
    paypalEmailController.text = payout.paypalEmail ?? '';
    notesController.text = payout.notes ?? '';
    failureReasonController.text = payout.failureReason ?? '';
    selectedStatus.value = payout.status;
    selectedPaymentMethod.value = payout.paymentMethod;
    selectedPeriodStart.value = payout.periodStart;
    selectedPeriodEnd.value = payout.periodEnd;
  }
  
  // Save payout
  Future<void> savePayout() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedRestaurantId.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a restaurant');
      return;
    }
    
    if (selectedPeriodStart.value == null || selectedPeriodEnd.value == null) {
      AppUtils.showErrorSnackbar('Please select payout period');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      // Find selected restaurant
      final restaurant = restaurants.firstWhereOrNull(
        (r) => r.id == selectedRestaurantId.value,
      );
      
      if (restaurant == null) {
        AppUtils.showErrorSnackbar('Restaurant not found');
        return;
      }
      
      final now = DateTime.now();
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final commission = double.tryParse(commissionController.text) ?? 0.0;
      final netAmount = amount - commission;
      
      final payoutData = {
        'restaurantId': selectedRestaurantId.value,
        'restaurantName': restaurant.title,
        'restaurantOwnerEmail': restaurant.email,
        'amount': amount,
        'commissionAmount': commission,
        'netAmount': netAmount,
        'currency': 'USD',
        'status': selectedStatus.value,
        'paymentMethod': selectedPaymentMethod.value,
        'transactionId': transactionIdController.text.trim().isEmpty 
            ? null 
            : transactionIdController.text.trim(),
        'bankAccountDetails': bankAccountController.text.trim().isEmpty 
            ? null 
            : bankAccountController.text.trim(),
        'paypalEmail': paypalEmailController.text.trim().isEmpty 
            ? null 
            : paypalEmailController.text.trim(),
        'notes': notesController.text.trim().isEmpty 
            ? null 
            : notesController.text.trim(),
        'failureReason': failureReasonController.text.trim().isEmpty 
            ? null 
            : failureReasonController.text.trim(),
        'periodStart': Timestamp.fromDate(selectedPeriodStart.value!),
        'periodEnd': Timestamp.fromDate(selectedPeriodEnd.value!),
        'requestedBy': currentUser.id,
      };
      
      String? payoutId;
      
      if (currentPayout.value != null) {
        // Update existing payout
        payoutId = currentPayout.value!.id;
        
        // Add processed/completed timestamps based on status
        if (selectedStatus.value == 'processing' && currentPayout.value!.status != 'processing') {
          payoutData['processedAt'] = Timestamp.fromDate(now);
          payoutData['processedBy'] = currentUser.id;
        } else if (selectedStatus.value == 'completed' && currentPayout.value!.status != 'completed') {
          payoutData['completedAt'] = Timestamp.fromDate(now);
          if (currentPayout.value!.processedAt == null) {
            payoutData['processedAt'] = Timestamp.fromDate(now);
            payoutData['processedBy'] = currentUser.id;
          }
        }
        
        await _firestoreService.updateDocument(
          collection: AppConstants.payoutsCollection,
          docId: payoutId,
          data: payoutData,
        );
        AppUtils.showSuccessSnackbar('Payout updated successfully');
      } else {
        // Create new payout
        payoutData['requestedAt'] = Timestamp.fromDate(now);
        payoutId = await _firestoreService.createDocument(
          collection: AppConstants.payoutsCollection,
          data: payoutData,
        );
        AppUtils.showSuccessSnackbar('Payout created successfully');
      }
      
      if (payoutId != null) {
        await loadPayouts(refresh: true);
        clearForm();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save payout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete payout
  Future<void> deletePayout(PayoutModel payout) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.payoutsCollection,
        docId: payout.id,
      );

      AppUtils.showSuccessSnackbar('Payout deleted successfully');
      await loadPayouts(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete payout: $e');
    }
  }

  // Update payout status
  Future<void> updatePayoutStatus(PayoutModel payout, String newStatus) async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }

      final now = DateTime.now();
      final updateData = <String, dynamic>{
        'status': newStatus,
      };

      // Add timestamps based on status
      if (newStatus == 'processing' && payout.status != 'processing') {
        updateData['processedAt'] = Timestamp.fromDate(now);
        updateData['processedBy'] = currentUser.id;
      } else if (newStatus == 'completed' && payout.status != 'completed') {
        updateData['completedAt'] = Timestamp.fromDate(now);
        if (payout.processedAt == null) {
          updateData['processedAt'] = Timestamp.fromDate(now);
          updateData['processedBy'] = currentUser.id;
        }
      }

      await _firestoreService.updateDocument(
        collection: AppConstants.payoutsCollection,
        docId: payout.id,
        data: updateData,
      );

      AppUtils.showSuccessSnackbar('Payout status updated successfully');
      await loadPayouts(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update payout status: $e');
    }
  }

  // Set filters
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterPayouts();
  }

  void setPaymentMethodFilter(String method) {
    selectedPaymentMethodFilter.value = method;
    _filterPayouts();
  }

  void setRestaurantFilter(String restaurantId) {
    selectedRestaurantFilter.value = restaurantId;
    _filterPayouts();
  }

  // Date picker helpers
  Future<void> selectPeriodStart(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPeriodStart.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedPeriodStart.value = picked;
    }
  }

  Future<void> selectPeriodEnd(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedPeriodEnd.value ?? DateTime.now(),
      firstDate: selectedPeriodStart.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedPeriodEnd.value = picked;
    }
  }

  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
