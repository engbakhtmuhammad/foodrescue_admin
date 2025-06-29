import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/payment_gateway_model.dart';
import '../utils/app_utils.dart';

class PaymentGatewayController extends GetxController {
  static PaymentGatewayController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final paymentGateways = <PaymentGatewayModel>[].obs;
  final filteredPaymentGateways = <PaymentGatewayModel>[].obs;
  final currentPaymentGateway = Rx<PaymentGatewayModel?>(null);
  
  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final transactionFeePercentageController = TextEditingController();
  final fixedTransactionFeeController = TextEditingController();
  final displayOrderController = TextEditingController();
  final configControllers = <String, TextEditingController>{}.obs;
  
  // Form variables
  final selectedType = 'stripe'.obs;
  final selectedIsActive = true.obs;
  final selectedIsDefault = false.obs;
  final selectedCurrencies = <String>[].obs;
  final uploadedLogoUrl = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedTypeFilter = 'all'.obs;
  final selectedStatusFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadPaymentGateways();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterPaymentGateways();
    });
    
    // Listen to type changes to update config fields
    selectedType.listen((type) {
      _updateConfigControllers(type);
    });
  }
  
  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    transactionFeePercentageController.dispose();
    fixedTransactionFeeController.dispose();
    displayOrderController.dispose();
    searchController.dispose();
    
    // Dispose config controllers
    for (var controller in configControllers.values) {
      controller.dispose();
    }
    
    super.onClose();
  }
  
  // Load payment gateways
  Future<void> loadPaymentGateways({bool refresh = false}) async {
    if (refresh) {
      paymentGateways.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.paymentGatewaysCollection,
        orderBy: 'displayOrder',
        descending: false,
      );
      
      if (query != null) {
        paymentGateways.value = query.docs
            .map((doc) => PaymentGatewayModel.fromFirestore(doc))
            .toList();
      }
      
      _filterPaymentGateways();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load payment gateways: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter payment gateways
  void _filterPaymentGateways() {
    var filtered = paymentGateways.where((gateway) {
      final matchesSearch = searchQuery.value.isEmpty ||
          gateway.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          gateway.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      final matchesType = selectedTypeFilter.value == 'all' ||
          gateway.type == selectedTypeFilter.value;
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          (selectedStatusFilter.value == 'active' && gateway.isActive) ||
          (selectedStatusFilter.value == 'inactive' && !gateway.isActive);
      
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
    
    filteredPaymentGateways.value = filtered;
  }
  
  // Update config controllers based on gateway type
  void _updateConfigControllers(String type) {
    // Dispose existing controllers
    for (var controller in configControllers.values) {
      controller.dispose();
    }
    configControllers.clear();
    
    // Create new controllers for required fields
    final requiredFields = PaymentGatewayModel.getRequiredConfigFields(type);
    for (String field in requiredFields) {
      configControllers[field] = TextEditingController();
    }
  }
  
  // Clear form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    transactionFeePercentageController.clear();
    fixedTransactionFeeController.clear();
    displayOrderController.clear();
    
    // Clear config controllers
    for (var controller in configControllers.values) {
      controller.clear();
    }
    
    selectedType.value = 'stripe';
    selectedIsActive.value = true;
    selectedIsDefault.value = false;
    selectedCurrencies.clear();
    uploadedLogoUrl.value = '';
    currentPaymentGateway.value = null;
  }
  
  // Load payment gateway for editing
  void loadPaymentGatewayForEdit(PaymentGatewayModel gateway) {
    currentPaymentGateway.value = gateway;
    nameController.text = gateway.name;
    descriptionController.text = gateway.description;
    transactionFeePercentageController.text = gateway.transactionFeePercentage.toString();
    fixedTransactionFeeController.text = gateway.fixedTransactionFee.toString();
    displayOrderController.text = gateway.displayOrder.toString();
    selectedType.value = gateway.type;
    selectedIsActive.value = gateway.isActive;
    selectedIsDefault.value = gateway.isDefault;
    selectedCurrencies.value = gateway.supportedCurrencies.toList();
    uploadedLogoUrl.value = gateway.logoUrl ?? '';
    
    // Load configuration values
    for (String field in configControllers.keys) {
      if (gateway.configuration.containsKey(field)) {
        configControllers[field]?.text = gateway.configuration[field].toString();
      }
    }
  }
  
  // Pick logo image
  Future<void> pickLogo() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: 'payment_gateway_logos',
    );
    
    if (imageUrl != null) {
      uploadedLogoUrl.value = imageUrl;
    }
  }
  
  // Toggle currency selection
  void toggleCurrency(String currency) {
    if (selectedCurrencies.contains(currency)) {
      selectedCurrencies.remove(currency);
    } else {
      selectedCurrencies.add(currency);
    }
  }
  
  // Save payment gateway
  Future<void> savePaymentGateway() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (selectedCurrencies.isEmpty) {
      AppUtils.showErrorSnackbar('Please select at least one supported currency');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      
      // Build configuration map
      final configuration = <String, dynamic>{};
      for (String field in configControllers.keys) {
        final value = configControllers[field]?.text.trim();
        if (value?.isNotEmpty == true) {
          configuration[field] = value;
        }
      }
      
      // Validate required configuration fields
      final requiredFields = PaymentGatewayModel.getRequiredConfigFields(selectedType.value);
      for (String field in requiredFields) {
        if (!configuration.containsKey(field) || configuration[field].toString().isEmpty) {
          AppUtils.showErrorSnackbar('${PaymentGatewayModel.getConfigFieldDisplayName(field)} is required');
          return;
        }
      }
      
      final gatewayData = {
        'name': nameController.text.trim(),
        'type': selectedType.value,
        'description': descriptionController.text.trim(),
        'isActive': selectedIsActive.value,
        'isDefault': selectedIsDefault.value,
        'configuration': configuration,
        'supportedCurrencies': selectedCurrencies.toList(),
        'transactionFeePercentage': double.tryParse(transactionFeePercentageController.text) ?? 0.0,
        'fixedTransactionFee': double.tryParse(fixedTransactionFeeController.text) ?? 0.0,
        'logoUrl': uploadedLogoUrl.value.isEmpty ? null : uploadedLogoUrl.value,
        'displayOrder': int.tryParse(displayOrderController.text) ?? 0,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      String? gatewayId;
      
      if (currentPaymentGateway.value != null) {
        // Update existing payment gateway
        gatewayId = currentPaymentGateway.value!.id;
        await _firestoreService.updateDocument(
          collection: AppConstants.paymentGatewaysCollection,
          docId: gatewayId,
          data: gatewayData,
        );
        AppUtils.showSuccessSnackbar('Payment gateway updated successfully');
      } else {
        // Create new payment gateway
        gatewayData['createdAt'] = Timestamp.fromDate(now);
        gatewayId = await _firestoreService.createDocument(
          collection: AppConstants.paymentGatewaysCollection,
          data: gatewayData,
        );
        AppUtils.showSuccessSnackbar('Payment gateway created successfully');
      }
      
      // If this gateway is set as default, remove default from others
      if (selectedIsDefault.value && gatewayId != null) {
        await _updateDefaultGateway(gatewayId);
      }
      
      if (gatewayId != null) {
        await loadPaymentGateways(refresh: true);
        clearForm();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save payment gateway: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update default gateway (remove default from others)
  Future<void> _updateDefaultGateway(String newDefaultId) async {
    try {
      // Get all gateways that are currently default
      final query = await _firestoreService.getCollection(
        collection: AppConstants.paymentGatewaysCollection,
        filters: [QueryFilter(field: 'isDefault', value: true)],
      );

      if (query != null) {
        for (var doc in query.docs) {
          if (doc.id != newDefaultId) {
            await _firestoreService.updateDocument(
              collection: AppConstants.paymentGatewaysCollection,
              docId: doc.id,
              data: {'isDefault': false},
            );
          }
        }
      }
    } catch (e) {
      // Log error but don't show to user as main operation succeeded
      print('Error updating default gateway: $e');
    }
  }

  // Delete payment gateway
  Future<void> deletePaymentGateway(PaymentGatewayModel gateway) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.paymentGatewaysCollection,
        docId: gateway.id,
      );

      AppUtils.showSuccessSnackbar('Payment gateway deleted successfully');
      await loadPaymentGateways(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete payment gateway: $e');
    }
  }

  // Toggle payment gateway status
  Future<void> togglePaymentGatewayStatus(PaymentGatewayModel gateway) async {
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.paymentGatewaysCollection,
        docId: gateway.id,
        data: {
          'isActive': !gateway.isActive,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      AppUtils.showSuccessSnackbar('Payment gateway status updated successfully');
      await loadPaymentGateways(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update payment gateway status: $e');
    }
  }

  // Set as default gateway
  Future<void> setAsDefaultGateway(PaymentGatewayModel gateway) async {
    try {
      // First remove default from all gateways
      await _updateDefaultGateway(gateway.id);

      // Then set this gateway as default
      await _firestoreService.updateDocument(
        collection: AppConstants.paymentGatewaysCollection,
        docId: gateway.id,
        data: {
          'isDefault': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      AppUtils.showSuccessSnackbar('Default payment gateway updated successfully');
      await loadPaymentGateways(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to set default payment gateway: $e');
    }
  }

  // Set filters
  void setTypeFilter(String type) {
    selectedTypeFilter.value = type;
    _filterPaymentGateways();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterPaymentGateways();
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
      return null; // Optional field
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number < 0) {
      return '$fieldName must be 0 or greater';
    }
    return null;
  }
}
