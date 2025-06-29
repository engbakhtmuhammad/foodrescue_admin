import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/menu_model.dart';
import '../utils/app_utils.dart';

class MenuController extends GetxController {
  static MenuController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final menus = <MenuModel>[].obs;
  final filteredMenus = <MenuModel>[].obs;
  final currentMenu = Rx<MenuModel?>(null);
  final categories = <String>[].obs;
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final preparationTimeController = TextEditingController();
  
  // Form variables
  final selectedIsVeg = true.obs;
  final selectedIsAvailable = true.obs;
  final uploadedImageUrl = ''.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategoryFilter = 'all'.obs;
  final selectedAvailabilityFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadMenus();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterMenus();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    preparationTimeController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load menus
  Future<void> loadMenus({bool refresh = false}) async {
    if (refresh) {
      menus.clear();
    }
    
    isLoading.value = true;
    
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurant's menus
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
            filters = [QueryFilter(field: 'pid', value: restaurantId)];
          } else {
            // No restaurant found for this owner
            isLoading.value = false;
            return;
          }
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.menusCollection,
        orderBy: 'title',
        descending: false,
        filters: filters,
      );
      
      if (query != null) {
        menus.value = query.docs
            .map((doc) => MenuModel.fromFirestore(doc))
            .toList();
        
        // Extract unique categories
        final uniqueCategories = menus
            .map((menu) => menu.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();
        categories.value = uniqueCategories;
      }
      
      _filterMenus();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load menus: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter menus
  void _filterMenus() {
    var filtered = menus.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((menu) =>
          menu.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          menu.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          menu.category.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Apply category filter
    if (selectedCategoryFilter.value != 'all') {
      filtered = filtered.where((menu) =>
          menu.category == selectedCategoryFilter.value
      ).toList();
    }
    
    // Apply availability filter
    if (selectedAvailabilityFilter.value != 'all') {
      final isAvailable = selectedAvailabilityFilter.value == 'available';
      filtered = filtered.where((menu) =>
          menu.isAvailable == isAvailable
      ).toList();
    }
    
    filteredMenus.value = filtered;
  }
  
  // Set category filter
  void setCategoryFilter(String category) {
    selectedCategoryFilter.value = category;
    _filterMenus();
  }
  
  // Set availability filter
  void setAvailabilityFilter(String availability) {
    selectedAvailabilityFilter.value = availability;
    _filterMenus();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    categoryController.clear();
    priceController.clear();
    preparationTimeController.clear();
    selectedIsVeg.value = true;
    selectedIsAvailable.value = true;
    uploadedImageUrl.value = '';
    currentMenu.value = null;
  }
  
  // Load menu for editing
  void loadMenuForEdit(MenuModel menu) {
    currentMenu.value = menu;
    titleController.text = menu.title;
    descriptionController.text = menu.description;
    categoryController.text = menu.category;
    priceController.text = menu.price.toString();
    preparationTimeController.text = menu.preparationTime.toString();
    selectedIsVeg.value = menu.isVeg;
    selectedIsAvailable.value = menu.isAvailable;
    uploadedImageUrl.value = menu.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: 'menu_images',
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }
  
  // Save menu
  Future<void> saveMenu() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a menu item image');
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
      
      // Get restaurant ID
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
      } else {
        // For admin, we need to select a restaurant (this would be handled in the form)
        AppUtils.showErrorSnackbar('Restaurant selection not implemented for admin');
        return;
      }
      
      final menuData = {
        'pid': restaurantId,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'img': uploadedImageUrl.value,
        'price': double.tryParse(priceController.text) ?? 0.0,
        'category': categoryController.text.trim(),
        'isVeg': selectedIsVeg.value,
        'isAvailable': selectedIsAvailable.value,
        'preparationTime': int.tryParse(preparationTimeController.text) ?? 15,
        'ingredients': <String>[], // This could be expanded in the form
        'updatedAt': Timestamp.fromDate(now),
      };
      
      if (currentMenu.value != null) {
        // Update existing menu
        await _firestoreService.updateDocument(
          collection: AppConstants.menusCollection,
          docId: currentMenu.value!.id,
          data: menuData,
        );
        AppUtils.showSuccessSnackbar('Menu item updated successfully');
      } else {
        // Create new menu
        menuData['createdAt'] = Timestamp.fromDate(now);
        await _firestoreService.createDocument(
          collection: AppConstants.menusCollection,
          data: menuData,
        );
        AppUtils.showSuccessSnackbar('Menu item created successfully');
      }
      
      clearForm();
      await loadMenus(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save menu item: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete menu
  Future<void> deleteMenu(MenuModel menu) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Menu Item',
      message: 'Are you sure you want to delete "${menu.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete menu image
      if (menu.img.isNotEmpty) {
        await _storageService.deleteFile(menu.img);
      }
      
      // Delete menu document
      await _firestoreService.deleteDocument(
        collection: AppConstants.menusCollection,
        docId: menu.id,
      );
      
      AppUtils.showSuccessSnackbar('Menu item deleted successfully');
      await loadMenus(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete menu item: $e');
    }
  }
  
  // Toggle menu availability
  Future<void> toggleMenuAvailability(MenuModel menu) async {
    try {
      final newAvailability = !menu.isAvailable;
      
      await _firestoreService.updateDocument(
        collection: AppConstants.menusCollection,
        docId: menu.id,
        data: {
          'isAvailable': newAvailability,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Menu availability updated successfully');
      await loadMenus(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update menu availability: $e');
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
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
