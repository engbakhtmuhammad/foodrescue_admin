import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/gallery_model.dart';
import '../utils/app_utils.dart';

class GalleryController extends GetxController {
  static GalleryController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final galleries = <GalleryModel>[].obs;
  final filteredGalleries = <GalleryModel>[].obs;
  final galleryCategories = <GalleryCategoryModel>[].obs;
  final currentGallery = Rx<GalleryModel?>(null);
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Form variables
  final selectedCategoryId = ''.obs;
  final uploadedImageUrl = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategoryFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadGalleryCategories();
    loadGalleries();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterGalleries();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load gallery categories
  Future<void> loadGalleryCategories({bool refresh = false}) async {
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurant's categories
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
            filters = [QueryFilter(field: 'pid', value: restaurantId)];
          }
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.galleryCategoriesCollection,
        orderBy: 'title',
        descending: false,
        filters: filters,
      );
      
      if (query != null) {
        galleryCategories.value = query.docs
            .map((doc) => GalleryCategoryModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load gallery categories: $e');
    }
  }
  
  // Load galleries
  Future<void> loadGalleries({bool refresh = false}) async {
    if (refresh) {
      galleries.clear();
    }
    
    isLoading.value = true;
    
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurant's galleries
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
            filters = [QueryFilter(field: 'pid', value: restaurantId)];
          } else {
            isLoading.value = false;
            return;
          }
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.galleriesCollection,
        orderBy: 'createdAt',
        descending: true,
        filters: filters,
      );
      
      if (query != null) {
        galleries.value = query.docs
            .map((doc) => GalleryModel.fromFirestore(doc))
            .toList();
      }
      
      _filterGalleries();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load galleries: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter galleries
  void _filterGalleries() {
    var filtered = galleries.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((gallery) =>
          gallery.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (gallery.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Apply category filter
    if (selectedCategoryFilter.value != 'all') {
      filtered = filtered.where((gallery) =>
          gallery.catId == selectedCategoryFilter.value
      ).toList();
    }
    
    filteredGalleries.value = filtered;
  }
  
  // Set category filter
  void setCategoryFilter(String categoryId) {
    selectedCategoryFilter.value = categoryId;
    _filterGalleries();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategoryId.value = '';
    uploadedImageUrl.value = '';
    currentGallery.value = null;
  }
  
  // Load gallery for editing
  void loadGalleryForEdit(GalleryModel gallery) {
    currentGallery.value = gallery;
    titleController.text = gallery.title;
    descriptionController.text = gallery.description ?? '';
    selectedCategoryId.value = gallery.catId;
    uploadedImageUrl.value = gallery.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: 'gallery_images',
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }
  
  // Create gallery category
  Future<void> createGalleryCategory(String title, String description) async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      String? restaurantId;
      if (_authService.isRestaurantOwner) {
        final restaurantQuery = await _firestoreService.getCollection(
          collection: AppConstants.restaurantsCollection,
          filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
          limit: 1,
        );
        
        if (restaurantQuery?.docs.isNotEmpty == true) {
          restaurantId = restaurantQuery!.docs.first.id;
        } else {
          AppUtils.showErrorSnackbar('No restaurant found for this user');
          return;
        }
      }
      
      final now = DateTime.now();
      final categoryData = {
        'pid': restaurantId ?? '',
        'title': title,
        'description': description.isEmpty ? null : description,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };
      
      await _firestoreService.createDocument(
        collection: AppConstants.galleryCategoriesCollection,
        data: categoryData,
      );
      
      AppUtils.showSuccessSnackbar('Gallery category created successfully');
      await loadGalleryCategories(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to create gallery category: $e');
    }
  }
  
  // Save gallery
  Future<void> saveGallery() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a gallery image');
      return;
    }
    
    if (selectedCategoryId.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a category');
      return;
    }
    
    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      final currentUser = _authService.currentUser.value;
      
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      String? restaurantId;
      if (_authService.isRestaurantOwner) {
        final restaurantQuery = await _firestoreService.getCollection(
          collection: AppConstants.restaurantsCollection,
          filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
          limit: 1,
        );
        
        if (restaurantQuery?.docs.isNotEmpty == true) {
          restaurantId = restaurantQuery!.docs.first.id;
        } else {
          AppUtils.showErrorSnackbar('No restaurant found for this user');
          return;
        }
      }
      
      final galleryData = {
        'pid': restaurantId ?? '',
        'catId': selectedCategoryId.value,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim().isEmpty 
            ? null 
            : descriptionController.text.trim(),
        'img': uploadedImageUrl.value,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      if (currentGallery.value != null) {
        // Update existing gallery
        await _firestoreService.updateDocument(
          collection: AppConstants.galleriesCollection,
          docId: currentGallery.value!.id,
          data: galleryData,
        );
        AppUtils.showSuccessSnackbar('Gallery image updated successfully');
      } else {
        // Create new gallery
        galleryData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.galleriesCollection,
          data: galleryData,
        );
        AppUtils.showSuccessSnackbar('Gallery image created successfully');
      }
      
      clearForm();
      await loadGalleries(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save gallery image: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete gallery
  Future<void> deleteGallery(GalleryModel gallery) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Gallery Image',
      message: 'Are you sure you want to delete "${gallery.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete gallery image
      if (gallery.img.isNotEmpty) {
        await _storageService.deleteFile(gallery.img);
      }
      
      // Delete gallery document
      await _firestoreService.deleteDocument(
        collection: AppConstants.galleriesCollection,
        docId: gallery.id,
      );
      
      AppUtils.showSuccessSnackbar('Gallery image deleted successfully');
      await loadGalleries(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete gallery image: $e');
    }
  }
  
  // Delete gallery category
  Future<void> deleteGalleryCategory(GalleryCategoryModel category) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Gallery Category',
      message: 'Are you sure you want to delete "${category.title}"? All images in this category will also be deleted.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete all galleries in this category
      final galleriesToDelete = galleries.where((gallery) => gallery.catId == category.id).toList();
      for (final gallery in galleriesToDelete) {
        await deleteGallery(gallery);
      }
      
      // Delete category document
      await _firestoreService.deleteDocument(
        collection: AppConstants.galleryCategoriesCollection,
        docId: category.id,
      );
      
      AppUtils.showSuccessSnackbar('Gallery category deleted successfully');
      await loadGalleryCategories(refresh: true);
      await loadGalleries(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete gallery category: $e');
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
