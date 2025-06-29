import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class SettingsController extends GetxController {
  static SettingsController get instance => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  
  // App Settings Controllers
  final appNameController = TextEditingController();
  final appVersionController = TextEditingController();
  final appDescriptionController = TextEditingController();
  final supportEmailController = TextEditingController();
  final supportPhoneController = TextEditingController();
  
  // Payment Settings Controllers
  final currencyController = TextEditingController();
  final currencySymbolController = TextEditingController();
  final taxRateController = TextEditingController();
  final deliveryChargeController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final freeDeliveryAboveController = TextEditingController();
  
  // Notification Settings
  final emailNotificationsEnabled = true.obs;
  final pushNotificationsEnabled = true.obs;
  final smsNotificationsEnabled = false.obs;
  final notificationEmailController = TextEditingController();
  
  // Business Settings Controllers
  final businessNameController = TextEditingController();
  final businessEmailController = TextEditingController();
  final businessAddressController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessWebsiteController = TextEditingController();
  
  // Order Settings
  final orderTimeoutController = TextEditingController();
  final maxOrdersPerDayController = TextEditingController();
  final autoAcceptOrders = false.obs;
  final allowOrderCancellation = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  
  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }
  
  void _disposeControllers() {
    appNameController.dispose();
    appVersionController.dispose();
    appDescriptionController.dispose();
    supportEmailController.dispose();
    supportPhoneController.dispose();
    currencyController.dispose();
    currencySymbolController.dispose();
    taxRateController.dispose();
    deliveryChargeController.dispose();
    minOrderAmountController.dispose();
    freeDeliveryAboveController.dispose();
    notificationEmailController.dispose();
    businessNameController.dispose();
    businessEmailController.dispose();
    businessAddressController.dispose();
    businessPhoneController.dispose();
    businessWebsiteController.dispose();
    orderTimeoutController.dispose();
    maxOrdersPerDayController.dispose();
  }
  
  // Load settings from Firestore
  Future<void> loadSettings() async {
    isLoading.value = true;
    
    try {
      final settingsDoc = await _firestoreService.getDocument(
        collection: AppConstants.settingsCollection,
        docId: 'app_settings',
      );
      
      if (settingsDoc != null && settingsDoc.exists) {
        final data = settingsDoc.data() as Map<String, dynamic>;
        
        // App Settings
        appNameController.text = data['appName'] ?? AppConstants.appName;
        appVersionController.text = data['appVersion'] ?? '1.0.0';
        appDescriptionController.text = data['appDescription'] ?? '';
        supportEmailController.text = data['supportEmail'] ?? '';
        supportPhoneController.text = data['supportPhone'] ?? '';
        
        // Payment Settings
        currencyController.text = data['currency'] ?? 'USD';
        currencySymbolController.text = data['currencySymbol'] ?? '\$';
        taxRateController.text = (data['taxRate'] ?? 0.0).toString();
        deliveryChargeController.text = (data['deliveryCharge'] ?? 0.0).toString();
        minOrderAmountController.text = (data['minOrderAmount'] ?? 0.0).toString();
        freeDeliveryAboveController.text = (data['freeDeliveryAbove'] ?? 0.0).toString();
        
        // Notification Settings
        emailNotificationsEnabled.value = data['emailNotificationsEnabled'] ?? true;
        pushNotificationsEnabled.value = data['pushNotificationsEnabled'] ?? true;
        smsNotificationsEnabled.value = data['smsNotificationsEnabled'] ?? false;
        notificationEmailController.text = data['notificationEmail'] ?? '';
        
        // Business Settings
        businessNameController.text = data['businessName'] ?? '';
        businessEmailController.text = data['businessEmail'] ?? '';
        businessAddressController.text = data['businessAddress'] ?? '';
        businessPhoneController.text = data['businessPhone'] ?? '';
        businessWebsiteController.text = data['businessWebsite'] ?? '';
        
        // Order Settings
        orderTimeoutController.text = (data['orderTimeout'] ?? 30).toString();
        maxOrdersPerDayController.text = (data['maxOrdersPerDay'] ?? 100).toString();
        autoAcceptOrders.value = data['autoAcceptOrders'] ?? false;
        allowOrderCancellation.value = data['allowOrderCancellation'] ?? true;
      } else {
        // Set default values
        _setDefaultValues();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load settings: $e');
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Set default values
  void _setDefaultValues() {
    appNameController.text = AppConstants.appName;
    appVersionController.text = '1.0.0';
    currencyController.text = 'USD';
    currencySymbolController.text = '\$';
    taxRateController.text = '0.0';
    deliveryChargeController.text = '0.0';
    minOrderAmountController.text = '0.0';
    freeDeliveryAboveController.text = '50.0';
    orderTimeoutController.text = '30';
    maxOrdersPerDayController.text = '100';
    emailNotificationsEnabled.value = true;
    pushNotificationsEnabled.value = true;
    smsNotificationsEnabled.value = false;
    autoAcceptOrders.value = false;
    allowOrderCancellation.value = true;
  }
  
  // Save settings to Firestore
  Future<void> saveSettings() async {
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      
      final settingsData = {
        // App Settings
        'appName': appNameController.text.trim(),
        'appVersion': appVersionController.text.trim(),
        'appDescription': appDescriptionController.text.trim(),
        'supportEmail': supportEmailController.text.trim(),
        'supportPhone': supportPhoneController.text.trim(),
        
        // Payment Settings
        'currency': currencyController.text.trim(),
        'currencySymbol': currencySymbolController.text.trim(),
        'taxRate': double.tryParse(taxRateController.text) ?? 0.0,
        'deliveryCharge': double.tryParse(deliveryChargeController.text) ?? 0.0,
        'minOrderAmount': double.tryParse(minOrderAmountController.text) ?? 0.0,
        'freeDeliveryAbove': double.tryParse(freeDeliveryAboveController.text) ?? 0.0,
        
        // Notification Settings
        'emailNotificationsEnabled': emailNotificationsEnabled.value,
        'pushNotificationsEnabled': pushNotificationsEnabled.value,
        'smsNotificationsEnabled': smsNotificationsEnabled.value,
        'notificationEmail': notificationEmailController.text.trim(),
        
        // Business Settings
        'businessName': businessNameController.text.trim(),
        'businessEmail': businessEmailController.text.trim(),
        'businessAddress': businessAddressController.text.trim(),
        'businessPhone': businessPhoneController.text.trim(),
        'businessWebsite': businessWebsiteController.text.trim(),
        
        // Order Settings
        'orderTimeout': int.tryParse(orderTimeoutController.text) ?? 30,
        'maxOrdersPerDay': int.tryParse(maxOrdersPerDayController.text) ?? 100,
        'autoAcceptOrders': autoAcceptOrders.value,
        'allowOrderCancellation': allowOrderCancellation.value,
        
        'updatedAt': Timestamp.fromDate(now),
      };
      
      // Check if settings document exists
      final settingsDoc = await _firestoreService.getDocument(
        collection: AppConstants.settingsCollection,
        docId: 'app_settings',
      );
      
      if (settingsDoc != null && settingsDoc.exists) {
        // Update existing settings
        await _firestoreService.updateDocument(
          collection: AppConstants.settingsCollection,
          docId: 'app_settings',
          data: settingsData,
        );
      } else {
        // Create new settings document
        settingsData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.settingsCollection,
          data: settingsData,
          docId: 'app_settings',
        );
      }
      
      AppUtils.showSuccessSnackbar('Settings saved successfully');
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save settings: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Reset to default values
  Future<void> resetToDefault() async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Reset Settings',
      message: 'Are you sure you want to reset all settings to default values? This action cannot be undone.',
      confirmText: 'Reset',
    );
    
    if (confirmed) {
      _setDefaultValues();
      AppUtils.showSuccessSnackbar('Settings reset to default values');
    }
  }
  
  // Get setting value by key
  Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    try {
      final settingsDoc = await _firestoreService.getDocument(
        collection: AppConstants.settingsCollection,
        docId: 'app_settings',
      );
      
      if (settingsDoc != null && settingsDoc.exists) {
        final data = settingsDoc.data() as Map<String, dynamic>;
        return data[key] ?? defaultValue;
      }
      
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
  
  // Update single setting
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.settingsCollection,
        docId: 'app_settings',
        data: {
          key: value,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update setting: $e');
    }
  }
}
