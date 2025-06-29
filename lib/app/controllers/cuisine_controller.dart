import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/cuisine_model.dart';
import '../utils/app_utils.dart';

class CuisineController extends GetxController {
  static CuisineController get instance => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final cuisines = <CuisineModel>[].obs;
  final filteredCuisines = <CuisineModel>[].obs;
  final currentCuisine = Rx<CuisineModel?>(null);
  
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
    loadCuisines();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterCuisines();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load cuisines
  Future<void> loadCuisines({bool refresh = false}) async {
    if (refresh) {
      cuisines.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.cuisinesCollection,
        orderBy: 'title',
        descending: false,
      );
      
      if (query != null) {
        cuisines.value = query.docs
            .map((doc) => CuisineModel.fromFirestore(doc))
            .toList();
      }
      
      _filterCuisines();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load cuisines: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter cuisines
  void _filterCuisines() {
    var filtered = cuisines.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((cuisine) =>
          cuisine.title.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      filtered = filtered.where((cuisine) =>
          cuisine.status == selectedStatusFilter.value
      ).toList();
    }
    
    filteredCuisines.value = filtered;
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterCuisines();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    selectedStatus.value = 'active';
    uploadedImageUrl.value = '';
    currentCuisine.value = null;
  }
  
  // Load cuisine for editing
  void loadCuisineForEdit(CuisineModel cuisine) {
    currentCuisine.value = cuisine;
    titleController.text = cuisine.title;
    selectedStatus.value = cuisine.status;
    uploadedImageUrl.value = cuisine.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: 'cuisine_images',
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }
  
  // Save cuisine
  Future<void> saveCuisine() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a cuisine image');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      
      final cuisineData = {
        'title': titleController.text.trim(),
        'img': uploadedImageUrl.value,
        'status': selectedStatus.value,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      if (currentCuisine.value != null) {
        // Update existing cuisine
        await _firestoreService.updateDocument(
          collection: AppConstants.cuisinesCollection,
          docId: currentCuisine.value!.id,
          data: cuisineData,
        );
        AppUtils.showSuccessSnackbar('Cuisine updated successfully');
      } else {
        // Create new cuisine
        cuisineData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.cuisinesCollection,
          data: cuisineData,
        );
        AppUtils.showSuccessSnackbar('Cuisine created successfully');
      }
      
      clearForm();
      await loadCuisines(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save cuisine: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete cuisine
  Future<void> deleteCuisine(CuisineModel cuisine) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Cuisine',
      message: 'Are you sure you want to delete "${cuisine.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete cuisine image
      if (cuisine.img.isNotEmpty) {
        await _storageService.deleteFile(cuisine.img);
      }
      
      // Delete cuisine document
      await _firestoreService.deleteDocument(
        collection: AppConstants.cuisinesCollection,
        docId: cuisine.id,
      );
      
      AppUtils.showSuccessSnackbar('Cuisine deleted successfully');
      await loadCuisines(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete cuisine: $e');
    }
  }
  
  // Toggle cuisine status
  Future<void> toggleCuisineStatus(CuisineModel cuisine) async {
    try {
      final newStatus = cuisine.status == 'active' ? 'inactive' : 'active';
      
      await _firestoreService.updateDocument(
        collection: AppConstants.cuisinesCollection,
        docId: cuisine.id,
        data: {
          'status': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Cuisine status updated successfully');
      await loadCuisines(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update cuisine status: $e');
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
