import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/banner_model.dart';
import '../utils/app_utils.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();
  
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final banners = <BannerModel>[].obs;
  final filteredBanners = <BannerModel>[].obs;
  final currentBanner = Rx<BannerModel?>(null);
  
  // Form controllers
  final titleController = TextEditingController();
  final linkController = TextEditingController();
  final sortOrderController = TextEditingController();
  
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
    loadBanners();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterBanners();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    linkController.dispose();
    sortOrderController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load banners
  Future<void> loadBanners({bool refresh = false}) async {
    if (refresh) {
      banners.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.bannersCollection,
        orderBy: 'sortOrder',
        descending: false,
      );
      
      if (query != null) {
        banners.value = query.docs
            .map((doc) => BannerModel.fromFirestore(doc))
            .toList();
      }
      
      _filterBanners();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load banners: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter banners
  void _filterBanners() {
    var filtered = banners.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((banner) =>
          banner.title.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      filtered = filtered.where((banner) =>
          banner.status == selectedStatusFilter.value
      ).toList();
    }
    
    filteredBanners.value = filtered;
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterBanners();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    linkController.clear();
    sortOrderController.clear();
    selectedStatus.value = 'active';
    uploadedImageUrl.value = '';
    currentBanner.value = null;
  }
  
  // Load banner for editing
  void loadBannerForEdit(BannerModel banner) {
    currentBanner.value = banner;
    titleController.text = banner.title;
    linkController.text = banner.link ?? '';
    sortOrderController.text = banner.sortOrder.toString();
    selectedStatus.value = banner.status;
    uploadedImageUrl.value = banner.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: AppConstants.bannerImagesPath,
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }
  
  // Save banner
  Future<void> saveBanner() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a banner image');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      
      final bannerData = {
        'title': titleController.text.trim(),
        'img': uploadedImageUrl.value,
        'link': linkController.text.trim().isEmpty ? null : linkController.text.trim(),
        'status': selectedStatus.value,
        'sortOrder': int.tryParse(sortOrderController.text) ?? 0,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      if (currentBanner.value != null) {
        // Update existing banner
        await _firestoreService.updateDocument(
          collection: AppConstants.bannersCollection,
          docId: currentBanner.value!.id,
          data: bannerData,
        );
        AppUtils.showSuccessSnackbar('Banner updated successfully');
      } else {
        // Create new banner
        bannerData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.bannersCollection,
          data: bannerData,
        );
        AppUtils.showSuccessSnackbar('Banner created successfully');
      }
      
      clearForm();
      await loadBanners(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save banner: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete banner
  Future<void> deleteBanner(BannerModel banner) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Banner',
      message: 'Are you sure you want to delete "${banner.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete banner image
      if (banner.img.isNotEmpty) {
        await _storageService.deleteFile(banner.img);
      }
      
      // Delete banner document
      await _firestoreService.deleteDocument(
        collection: AppConstants.bannersCollection,
        docId: banner.id,
      );
      
      AppUtils.showSuccessSnackbar('Banner deleted successfully');
      await loadBanners(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete banner: $e');
    }
  }
  
  // Toggle banner status
  Future<void> toggleBannerStatus(BannerModel banner) async {
    try {
      final newStatus = banner.status == 'active' ? 'inactive' : 'active';
      
      await _firestoreService.updateDocument(
        collection: AppConstants.bannersCollection,
        docId: banner.id,
        data: {
          'status': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Banner status updated successfully');
      await loadBanners(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update banner status: $e');
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
    if (int.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
