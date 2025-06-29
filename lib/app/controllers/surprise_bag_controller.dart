import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/surprise_bag_model.dart';
import '../models/restaurant_model.dart';
import '../models/cuisine_model.dart';
import '../utils/app_utils.dart';

class SurpriseBagController extends GetxController {
  static SurpriseBagController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final surpriseBags = <SurpriseBagModel>[].obs;
  final filteredSurpriseBags = <SurpriseBagModel>[].obs;
  final currentSurpriseBag = Rx<SurpriseBagModel?>(null);
  final restaurants = <RestaurantModel>[].obs;
  final availableCuisines = <CuisineModel>[].obs;
  final categories = <String>[].obs;
  
  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final originalPriceController = TextEditingController();
  final discountedPriceController = TextEditingController();
  final itemsLeftController = TextEditingController();
  final totalItemsController = TextEditingController();
  final pickupInstructionsController = TextEditingController();
  final pickupAddressController = TextEditingController();
  final dietaryInfoController = TextEditingController();
  
  // Time controllers
  final todayPickupStartController = TextEditingController();
  final todayPickupEndController = TextEditingController();
  final tomorrowPickupStartController = TextEditingController();
  final tomorrowPickupEndController = TextEditingController();
  
  // Form variables
  final selectedRestaurantId = ''.obs;
  final selectedCategoryId = ''.obs;
  final selectedPickupType = 'today'.obs;
  final selectedIsVegetarian = false.obs;
  final selectedIsVegan = false.obs;
  final selectedIsGlutenFree = false.obs;
  final selectedIsAvailable = true.obs;
  final selectedStatus = 'active'.obs;
  final uploadedImageUrl = ''.obs;
  final possibleItems = <String>[].obs;
  final allergens = <String>[].obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategoryFilter = 'all'.obs;
  final selectedStatusFilter = 'all'.obs;
  final selectedRestaurantFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadSurpriseBags();
    loadRestaurants();
    loadCuisines();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterSurpriseBags();
    });
  }
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    originalPriceController.dispose();
    discountedPriceController.dispose();
    itemsLeftController.dispose();
    totalItemsController.dispose();
    pickupInstructionsController.dispose();
    pickupAddressController.dispose();
    dietaryInfoController.dispose();
    todayPickupStartController.dispose();
    todayPickupEndController.dispose();
    tomorrowPickupStartController.dispose();
    tomorrowPickupEndController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load surprise bags
  Future<void> loadSurpriseBags({bool refresh = false}) async {
    if (refresh) {
      surpriseBags.clear();
    }
    
    isLoading.value = true;
    
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      List<QueryFilter> filters = [];
      
      // If restaurant owner, only show their surprise bags
      if (currentUser.role == AppConstants.restaurantOwnerRole) {
        // Find restaurant owned by current user
        final restaurantQuery = await _firestoreService.getCollection(
          collection: AppConstants.restaurantsCollection,
          filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
          limit: 1,
        );
        
        if (restaurantQuery?.docs.isNotEmpty == true) {
          final restaurantId = restaurantQuery!.docs.first.id;
          filters.add(QueryFilter(field: 'restaurantId', value: restaurantId));
        } else {
          // No restaurant found for this owner
          surpriseBags.clear();
          _filterSurpriseBags();
          return;
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.surpriseBagsCollection,
        orderBy: 'createdAt',
        descending: true,
        filters: filters,
      );
      
      if (query != null) {
        surpriseBags.value = query.docs
            .map((doc) => SurpriseBagModel.fromFirestore(doc))
            .toList();
        
        // Extract unique categories
        final uniqueCategories = surpriseBags
            .map((bag) => bag.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();
        categories.value = uniqueCategories;
      }
      
      _filterSurpriseBags();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load surprise bags: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load restaurants for dropdown
  Future<void> loadRestaurants() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) return;

      List<QueryFilter> filters = [];

      // If restaurant owner, only show their restaurant
      if (currentUser.role == AppConstants.restaurantOwnerRole) {
        filters.add(QueryFilter(field: 'ownerId', value: currentUser.id));
      }

      final query = await _firestoreService.getCollection(
        collection: AppConstants.restaurantsCollection,
        orderBy: 'title',
        descending: false,
        filters: filters,
      );

      if (query != null) {
        restaurants.value = query.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .toList();

        // Auto-select restaurant if only one available (restaurant owner)
        if (restaurants.length == 1) {
          selectedRestaurantId.value = restaurants.first.id;
        }
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load restaurants: $e');
    }
  }

  // Load cuisines for category dropdown
  Future<void> loadCuisines() async {
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.cuisinesCollection,
        orderBy: 'title',
        descending: false,
        filters: [QueryFilter(field: 'status', value: 'active')],
      );

      if (query != null) {
        availableCuisines.value = query.docs
            .map((doc) => CuisineModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load cuisines: $e');
    }
  }
  
  // Filter surprise bags
  void _filterSurpriseBags() {
    var filtered = surpriseBags.where((bag) {
      final matchesSearch = searchQuery.value.isEmpty ||
          bag.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          bag.description.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      final matchesCategory = selectedCategoryFilter.value == 'all' ||
          bag.category == selectedCategoryFilter.value;
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          bag.status == selectedStatusFilter.value;
      
      final matchesRestaurant = selectedRestaurantFilter.value == 'all' ||
          bag.restaurantId == selectedRestaurantFilter.value;
      
      return matchesSearch && matchesCategory && matchesStatus && matchesRestaurant;
    }).toList();
    
    filteredSurpriseBags.value = filtered;
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    categoryController.clear();
    originalPriceController.clear();
    discountedPriceController.clear();
    itemsLeftController.clear();
    totalItemsController.clear();
    pickupInstructionsController.clear();
    pickupAddressController.clear();
    dietaryInfoController.clear();
    todayPickupStartController.clear();
    todayPickupEndController.clear();
    tomorrowPickupStartController.clear();
    tomorrowPickupEndController.clear();
    
    selectedRestaurantId.value = restaurants.length == 1 ? restaurants.first.id : '';
    selectedCategoryId.value = '';
    selectedPickupType.value = 'today';
    selectedIsVegetarian.value = false;
    selectedIsVegan.value = false;
    selectedIsGlutenFree.value = false;
    selectedIsAvailable.value = true;
    selectedStatus.value = 'active';
    uploadedImageUrl.value = '';
    possibleItems.clear();
    allergens.clear();
    currentSurpriseBag.value = null;
  }

  // Load surprise bag for editing
  void loadSurpriseBagForEdit(SurpriseBagModel bag) {
    currentSurpriseBag.value = bag;
    titleController.text = bag.title;
    descriptionController.text = bag.description;
    categoryController.text = bag.category;
    originalPriceController.text = bag.originalPrice.toString();
    discountedPriceController.text = bag.discountedPrice.toString();
    itemsLeftController.text = bag.itemsLeft.toString();
    totalItemsController.text = bag.totalItems.toString();
    pickupInstructionsController.text = bag.pickupInstructions;
    pickupAddressController.text = bag.pickupAddress;
    dietaryInfoController.text = bag.dietaryInfo;
    todayPickupStartController.text = bag.todayPickupStart;
    todayPickupEndController.text = bag.todayPickupEnd;
    tomorrowPickupStartController.text = bag.tomorrowPickupStart;
    tomorrowPickupEndController.text = bag.tomorrowPickupEnd;

    selectedRestaurantId.value = bag.restaurantId;
    // Find the cuisine ID that matches the bag's category
    final matchingCuisine = availableCuisines.firstWhereOrNull(
      (cuisine) => cuisine.title == bag.category,
    );
    selectedCategoryId.value = matchingCuisine?.id ?? '';
    selectedPickupType.value = bag.pickupType;
    selectedIsVegetarian.value = bag.isVegetarian;
    selectedIsVegan.value = bag.isVegan;
    selectedIsGlutenFree.value = bag.isGlutenFree;
    selectedIsAvailable.value = bag.isAvailable;
    selectedStatus.value = bag.status;
    uploadedImageUrl.value = bag.img;
    possibleItems.value = bag.possibleItems.toList();
    allergens.value = bag.allergens.toList();
  }

  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: AppConstants.surpriseBagImagesPath,
    );

    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
    }
  }

  // Add possible item
  void addPossibleItem(String item) {
    if (item.trim().isNotEmpty && !possibleItems.contains(item.trim())) {
      possibleItems.add(item.trim());
    }
  }

  // Remove possible item
  void removePossibleItem(String item) {
    possibleItems.remove(item);
  }

  // Add allergen
  void addAllergen(String allergen) {
    if (allergen.trim().isNotEmpty && !allergens.contains(allergen.trim())) {
      allergens.add(allergen.trim());
    }
  }

  // Remove allergen
  void removeAllergen(String allergen) {
    allergens.remove(allergen);
  }

  // Save surprise bag
  Future<void> saveSurpriseBag() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a surprise bag image');
      return;
    }

    if (selectedRestaurantId.value.isEmpty) {
      AppUtils.showErrorSnackbar('Restaurant not found');
      return;
    }

    if (selectedCategoryId.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a category');
      return;
    }

    isLoading.value = true;

    try {
      final now = DateTime.now();
      final originalPrice = double.tryParse(originalPriceController.text) ?? 0.0;
      final discountedPrice = double.tryParse(discountedPriceController.text) ?? 0.0;

      if (originalPrice <= discountedPrice) {
        AppUtils.showErrorSnackbar('Original price must be higher than discounted price');
        isLoading.value = false;
        return;
      }

      // Get the selected cuisine title
      final selectedCuisine = availableCuisines.firstWhereOrNull(
        (cuisine) => cuisine.id == selectedCategoryId.value,
      );

      final bagData = {
        'restaurantId': selectedRestaurantId.value,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'img': uploadedImageUrl.value,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'discountPercentage': ((originalPrice - discountedPrice) / originalPrice) * 100,
        'itemsLeft': int.tryParse(itemsLeftController.text) ?? 0,
        'totalItems': int.tryParse(totalItemsController.text) ?? 0,
        'category': selectedCuisine?.title ?? '',
        'isAvailable': selectedIsAvailable.value,
        'status': selectedStatus.value,
        'pickupType': selectedPickupType.value,
        'todayPickupStart': todayPickupStartController.text.trim(),
        'todayPickupEnd': todayPickupEndController.text.trim(),
        'tomorrowPickupStart': tomorrowPickupStartController.text.trim(),
        'tomorrowPickupEnd': tomorrowPickupEndController.text.trim(),
        'pickupInstructions': pickupInstructionsController.text.trim(),
        'distance': 0.0, // Distance will be calculated in user app
        'pickupAddress': pickupAddressController.text.trim(),
        'pickupLatitude': 0.0, // This could be set from address geocoding
        'pickupLongitude': 0.0, // This could be set from address geocoding
        'possibleItems': possibleItems.toList(),
        'allergens': allergens.toList(),
        'isVegetarian': selectedIsVegetarian.value,
        'isVegan': selectedIsVegan.value,
        'isGlutenFree': selectedIsGlutenFree.value,
        'dietaryInfo': dietaryInfoController.text.trim(),
        'rating': 0.0,
        'totalReviews': 0,
        'totalSold': 0,
        'updatedAt': Timestamp.fromDate(now),
      };

      String? bagId;

      if (currentSurpriseBag.value != null) {
        // Update existing surprise bag
        bagId = currentSurpriseBag.value!.id;
        await _firestoreService.updateDocument(
          collection: AppConstants.surpriseBagsCollection,
          docId: bagId,
          data: bagData,
        );
        AppUtils.showSuccessSnackbar('Surprise bag updated successfully');
      } else {
        // Create new surprise bag
        bagData['createdAt'] = Timestamp.fromDate(now);
        bagId = await _firestoreService.createDocument(
          collection: AppConstants.surpriseBagsCollection,
          data: bagData,
        );
        AppUtils.showSuccessSnackbar('Surprise bag created successfully');
      }

      if (bagId != null) {
        // Refresh the surprise bags list in the background
        await loadSurpriseBags(refresh: true);

        // Clear the form for next entry but stay on the same page
        clearForm();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save surprise bag: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete surprise bag
  Future<void> deleteSurpriseBag(SurpriseBagModel bag) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.surpriseBagsCollection,
        docId: bag.id,
      );

      AppUtils.showSuccessSnackbar('Surprise bag deleted successfully');
      await loadSurpriseBags(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete surprise bag: $e');
    }
  }

  // Toggle surprise bag availability
  Future<void> toggleSurpriseBagAvailability(SurpriseBagModel bag) async {
    try {
      final newAvailability = !bag.isAvailable;

      await _firestoreService.updateDocument(
        collection: AppConstants.surpriseBagsCollection,
        docId: bag.id,
        data: {
          'isAvailable': newAvailability,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      AppUtils.showSuccessSnackbar('Surprise bag availability updated successfully');
      await loadSurpriseBags(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update surprise bag availability: $e');
    }
  }

  // Update items left
  Future<void> updateItemsLeft(SurpriseBagModel bag, int newItemsLeft) async {
    try {
      final status = newItemsLeft <= 0 ? 'sold_out' : 'active';

      await _firestoreService.updateDocument(
        collection: AppConstants.surpriseBagsCollection,
        docId: bag.id,
        data: {
          'itemsLeft': newItemsLeft,
          'status': status,
          'isAvailable': newItemsLeft > 0,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          if (newItemsLeft <= 0) 'lastSoldAt': Timestamp.fromDate(DateTime.now()),
        },
      );

      AppUtils.showSuccessSnackbar('Items left updated successfully');
      await loadSurpriseBags(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update items left: $e');
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
}
