import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/facility_model.dart';
import '../utils/app_utils.dart';

class FacilityController extends GetxController {
  static FacilityController get instance => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final facilities = <FacilityModel>[].obs;
  final filteredFacilities = <FacilityModel>[].obs;
  final currentFacility = Rx<FacilityModel?>(null);
  
  // Form controllers
  final titleController = TextEditingController();
  
  // Form variables
  final selectedStatus = 'active'.obs;
  final uploadedImageUrl = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadFacilities();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterFacilities();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load facilities
  Future<void> loadFacilities({bool refresh = false}) async {
    if (refresh) {
      facilities.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.facilitiesCollection,
        orderBy: 'title',
        descending: false,
      );
      
      if (query != null) {
        facilities.value = query.docs
            .map((doc) => FacilityModel.fromFirestore(doc))
            .toList();
      }
      
      _filterFacilities();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load facilities: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter facilities
  void _filterFacilities() {
    var filtered = facilities.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((facility) =>
          facility.title.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      filtered = filtered.where((facility) =>
          facility.status == selectedStatusFilter.value
      ).toList();
    }
    
    filteredFacilities.value = filtered;
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterFacilities();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    selectedStatus.value = 'active';
    uploadedImageUrl.value = '';
    currentFacility.value = null;
  }
  
  // Load facility for editing
  void loadFacilityForEdit(FacilityModel facility) {
    currentFacility.value = facility;
    titleController.text = facility.title;
    selectedStatus.value = facility.status;
    uploadedImageUrl.value = facility.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: 'facility_images',
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }
  
  // Save facility
  Future<void> saveFacility() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a facility image');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      
      final facilityData = {
        'title': titleController.text.trim(),
        'img': uploadedImageUrl.value,
        'status': selectedStatus.value,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      if (currentFacility.value != null) {
        // Update existing facility
        await _firestoreService.updateDocument(
          collection: AppConstants.facilitiesCollection,
          docId: currentFacility.value!.id,
          data: facilityData,
        );
        AppUtils.showSuccessSnackbar('Facility updated successfully');
      } else {
        // Create new facility
        facilityData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.facilitiesCollection,
          data: facilityData,
        );
        AppUtils.showSuccessSnackbar('Facility created successfully');
      }
      
      clearForm();
      await loadFacilities(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save facility: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete facility
  Future<void> deleteFacility(FacilityModel facility) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Facility',
      message: 'Are you sure you want to delete "${facility.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete facility image
      if (facility.img.isNotEmpty) {
        await _storageService.deleteFile(facility.img);
      }
      
      // Delete facility document
      await _firestoreService.deleteDocument(
        collection: AppConstants.facilitiesCollection,
        docId: facility.id,
      );
      
      AppUtils.showSuccessSnackbar('Facility deleted successfully');
      await loadFacilities(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete facility: $e');
    }
  }
  
  // Toggle facility status
  Future<void> toggleFacilityStatus(FacilityModel facility) async {
    try {
      final newStatus = facility.status == 'active' ? 'inactive' : 'active';
      
      await _firestoreService.updateDocument(
        collection: AppConstants.facilitiesCollection,
        docId: facility.id,
        data: {
          'status': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Facility status updated successfully');
      await loadFacilities(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update facility status: $e');
    }
  }
  
  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
