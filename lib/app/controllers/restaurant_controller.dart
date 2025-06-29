import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/restaurant_model.dart';
import '../models/cuisine_model.dart';
import '../models/facility_model.dart';
import '../utils/app_utils.dart';

class RestaurantController extends GetxController {
  static RestaurantController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final restaurants = <RestaurantModel>[].obs;
  final filteredRestaurants = <RestaurantModel>[].obs;
  final availableCuisines = <CuisineModel>[].obs;
  final availableFacilities = <FacilityModel>[].obs;
  final currentRestaurant = Rx<RestaurantModel?>(null);
  
  // Form controllers
  final titleController = TextEditingController();
  final shortDescriptionController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final certificateCodeController = TextEditingController();
  final fullAddressController = TextEditingController();
  final pincodeController = TextEditingController();
  final areaController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final showRadiusController = TextEditingController();
  final popularDishesController = TextEditingController();
  final mondayThursdayOfferController = TextEditingController();
  final mondayThursdayOfferDescController = TextEditingController();
  final fridaySundayOfferController = TextEditingController();
  final fridaySundayOfferDescController = TextEditingController();
  final approxPriceController = TextEditingController();
  final ratingController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  
  // Form variables
  final selectedStatus = 'active'.obs;
  final selectedTableBookingShow = true.obs;
  final selectedCuisines = <String>[].obs;
  final selectedFacilities = <String>[].obs;
  final selectedImagePath = ''.obs;
  final uploadedImageUrl = ''.obs;
  
  // Pagination
  final currentPage = 0.obs;
  final hasMoreData = true.obs;
  DocumentSnapshot? lastDocument;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatusFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadRestaurants();
    loadCuisines();
    loadFacilities();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterRestaurants();
    });
  }
  
  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }
  
  void _disposeControllers() {
    titleController.dispose();
    shortDescriptionController.dispose();
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    certificateCodeController.dispose();
    fullAddressController.dispose();
    pincodeController.dispose();
    areaController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    showRadiusController.dispose();
    popularDishesController.dispose();
    mondayThursdayOfferController.dispose();
    mondayThursdayOfferDescController.dispose();
    fridaySundayOfferController.dispose();
    fridaySundayOfferDescController.dispose();
    approxPriceController.dispose();
    ratingController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    searchController.dispose();
  }
  
  // Load restaurants
  Future<void> loadRestaurants({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      lastDocument = null;
      hasMoreData.value = true;
      restaurants.clear();
    }
    
    if (!hasMoreData.value) return;
    
    isLoading.value = true;
    
    try {
      List<QueryFilter>? filters;
      
      // If restaurant owner, only show their restaurants
      if (_authService.isRestaurantOwner) {
        final currentUser = _authService.currentUser.value;
        if (currentUser != null) {
          filters = [QueryFilter(field: 'ownerId', value: currentUser.id)];
        }
      }
      
      final query = await _firestoreService.getCollection(
        collection: AppConstants.restaurantsCollection,
        limit: AppConstants.itemsPerPage,
        startAfter: lastDocument,
        orderBy: 'createdAt',
        descending: true,
        filters: filters,
      );
      
      if (query != null && query.docs.isNotEmpty) {
        final List<RestaurantModel> newRestaurants = [];
        for (var doc in query.docs) {
          try {
            final restaurant = RestaurantModel.fromFirestore(doc);
            newRestaurants.add(restaurant);
          } catch (e) {
            print('Error parsing restaurant ${doc.id}: $e');
            // Skip this restaurant and continue with others
            continue;
          }
        }
        
        if (refresh) {
          restaurants.value = newRestaurants;
        } else {
          restaurants.addAll(newRestaurants);
        }
        
        lastDocument = query.docs.last;
        hasMoreData.value = query.docs.length == AppConstants.itemsPerPage;
        currentPage.value++;
      } else {
        hasMoreData.value = false;
      }
      
      _filterRestaurants();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load restaurants: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load cuisines
  Future<void> loadCuisines() async {
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.cuisinesCollection,
        filters: [QueryFilter(field: 'status', value: 'active')],
        orderBy: 'title',
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
  
  // Load facilities
  Future<void> loadFacilities() async {
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.facilitiesCollection,
        filters: [QueryFilter(field: 'status', value: 'active')],
        orderBy: 'title',
      );
      
      if (query != null) {
        availableFacilities.value = query.docs
            .map((doc) => FacilityModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load facilities: $e');
    }
  }
  
  // Filter restaurants
  void _filterRestaurants() {
    var filtered = restaurants.toList();
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((restaurant) =>
          restaurant.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          restaurant.area.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          restaurant.email.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    if (selectedStatusFilter.value != 'all') {
      filtered = filtered.where((restaurant) =>
          restaurant.status == selectedStatusFilter.value
      ).toList();
    }
    
    filteredRestaurants.value = filtered;
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterRestaurants();
  }
  
  // Clear form
  void clearForm() {
    titleController.clear();
    shortDescriptionController.clear();
    emailController.clear();
    passwordController.clear();
    mobileController.clear();
    certificateCodeController.clear();
    fullAddressController.clear();
    pincodeController.clear();
    areaController.clear();
    latitudeController.clear();
    longitudeController.clear();
    showRadiusController.clear();
    popularDishesController.clear();
    mondayThursdayOfferController.clear();
    mondayThursdayOfferDescController.clear();
    fridaySundayOfferController.clear();
    fridaySundayOfferDescController.clear();
    approxPriceController.clear();
    ratingController.clear();
    openTimeController.clear();
    closeTimeController.clear();
    
    selectedStatus.value = 'active';
    selectedTableBookingShow.value = true;
    selectedCuisines.clear();
    selectedFacilities.clear();
    selectedImagePath.value = '';
    uploadedImageUrl.value = '';
    currentRestaurant.value = null;
  }
  
  // Load restaurant for editing
  void loadRestaurantForEdit(RestaurantModel restaurant) {
    currentRestaurant.value = restaurant;
    
    titleController.text = restaurant.title;
    shortDescriptionController.text = restaurant.shortDescription;
    emailController.text = restaurant.email;
    passwordController.text = restaurant.password;
    mobileController.text = restaurant.mobile;
    certificateCodeController.text = restaurant.certificateCode ?? '';
    fullAddressController.text = restaurant.fullAddress;
    pincodeController.text = restaurant.pincode;
    areaController.text = restaurant.area;
    latitudeController.text = restaurant.latitude.toString();
    longitudeController.text = restaurant.longitude.toString();
    showRadiusController.text = restaurant.showRadius.toString();
    popularDishesController.text = restaurant.popularDishes;
    mondayThursdayOfferController.text = restaurant.mondayThursdayOffer;
    mondayThursdayOfferDescController.text = restaurant.mondayThursdayOfferDesc;
    fridaySundayOfferController.text = restaurant.fridaySundayOffer;
    fridaySundayOfferDescController.text = restaurant.fridaySundayOfferDesc;
    approxPriceController.text = restaurant.approxPrice.toString();
    ratingController.text = restaurant.rating.toString();
    openTimeController.text = restaurant.openTime;
    closeTimeController.text = restaurant.closeTime;
    
    selectedStatus.value = restaurant.status;
    selectedTableBookingShow.value = restaurant.tShow;
    selectedCuisines.value = restaurant.cuisines;
    selectedFacilities.value = restaurant.facilities;
    uploadedImageUrl.value = restaurant.img;
  }
  
  // Pick image
  Future<void> pickImage() async {
    final imageUrl = await _storageService.pickAndUploadImage(
      storagePath: AppConstants.restaurantImagesPath,
    );
    
    if (imageUrl != null) {
      uploadedImageUrl.value = imageUrl;
      selectedImagePath.value = imageUrl;
    }
  }
  
  // Toggle cuisine selection
  void toggleCuisineSelection(String cuisineId) {
    if (selectedCuisines.contains(cuisineId)) {
      selectedCuisines.remove(cuisineId);
    } else {
      selectedCuisines.add(cuisineId);
    }
  }
  
  // Toggle facility selection
  void toggleFacilitySelection(String facilityId) {
    if (selectedFacilities.contains(facilityId)) {
      selectedFacilities.remove(facilityId);
    } else {
      selectedFacilities.add(facilityId);
    }
  }
  
  // Save restaurant
  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (uploadedImageUrl.value.isEmpty) {
      AppUtils.showErrorSnackbar('Please select a restaurant image');
      return;
    }

    if (selectedCuisines.isEmpty) {
      AppUtils.showErrorSnackbar('Please select at least one cuisine');
      return;
    }

    // Additional validation for new restaurants
    if (currentRestaurant.value == null) {
      // Validate password strength for new restaurants
      final password = passwordController.text.trim();
      if (password.length < AppConstants.minPasswordLength) {
        AppUtils.showErrorSnackbar('Password must be at least ${AppConstants.minPasswordLength} characters long');
        return;
      }

      // Check if email is valid
      if (!AppUtils.isValidEmail(emailController.text.trim())) {
        AppUtils.showErrorSnackbar('Please enter a valid email address');
        return;
      }
    }

    isLoading.value = true;
    
    try {
      final now = DateTime.now();
      final currentUser = _authService.currentUser.value;
      
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      final restaurantData = {
        'title': titleController.text.trim(),
        'img': uploadedImageUrl.value,
        'status': selectedStatus.value,
        'tShow': selectedTableBookingShow.value,
        'rating': double.tryParse(ratingController.text) ?? 0.0,
        'approxPrice': double.tryParse(approxPriceController.text) ?? 0.0,
        'openTime': openTimeController.text.trim(),
        'closeTime': closeTimeController.text.trim(),
        'certificateCode': certificateCodeController.text.trim(),
        'mobile': mobileController.text.trim(),
        'shortDescription': shortDescriptionController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'cuisines': selectedCuisines.toList(),
        'facilities': selectedFacilities.toList(),
        'fullAddress': fullAddressController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'area': areaController.text.trim(),
        'latitude': double.tryParse(latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(longitudeController.text) ?? 0.0,
        'showRadius': double.tryParse(showRadiusController.text) ?? 5.0,
        'popularDishes': popularDishesController.text.trim(),
        'mondayThursdayOffer': mondayThursdayOfferController.text.trim(),
        'mondayThursdayOfferDesc': mondayThursdayOfferDescController.text.trim(),
        'fridaySundayOffer': fridaySundayOfferController.text.trim(),
        'fridaySundayOfferDesc': fridaySundayOfferDescController.text.trim(),
        'ownerId': _authService.isAdmin ? currentUser.id : currentUser.id,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      String? restaurantId;
      
      if (currentRestaurant.value != null) {
        // Update existing restaurant
        restaurantId = currentRestaurant.value!.id;

        // Don't include password in update data
        final updateData = Map<String, dynamic>.from(restaurantData);
        updateData.remove('password');

        await _firestoreService.updateDocument(
          collection: AppConstants.restaurantsCollection,
          docId: restaurantId,
          data: updateData,
        );
        AppUtils.showSuccessSnackbar('Restaurant updated successfully');
      } else {
        // Create new restaurant
        String? restaurantOwnerId;

        try {
          // Check if email already exists
          final emailAlreadyExists = await _authService.emailExists(emailController.text.trim());
          if (emailAlreadyExists) {
            AppUtils.showErrorSnackbar('An account with this email already exists. Please use a different email address.');
            return;
          }

          // Debug: Test basic Firestore access
          print('Testing Firestore access before user creation...');

          // Show progress message
          AppUtils.showLoadingDialog(message: 'Creating restaurant owner account...');

          // First, create the restaurant owner user account
          print('Creating restaurant owner account...');
          print('Email: ${emailController.text.trim()}');
          print('Role: ${AppConstants.restaurantOwnerRole}');

          restaurantOwnerId = await _authService.createUserAccount(
            name: titleController.text.trim(), // Use restaurant name as owner name for now
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
            role: AppConstants.restaurantOwnerRole,
            mobile: mobileController.text.trim(),
          );

          print('Restaurant owner ID created: $restaurantOwnerId');

          if (restaurantOwnerId == null) {
            AppUtils.hideLoadingDialog();
            AppUtils.showErrorSnackbar('Failed to create restaurant owner account');
            return;
          }

          // Update progress message
          AppUtils.hideLoadingDialog();
          AppUtils.showLoadingDialog(message: 'Creating restaurant...');

          // Update restaurant data with the created user ID
          restaurantData['ownerId'] = restaurantOwnerId;
          restaurantData['createdAt'] = Timestamp.fromDate(now);

          // Don't store password in restaurant document
          restaurantData.remove('password');

          // Create the restaurant document
          restaurantId = await _firestoreService.createDocument(
            collection: AppConstants.restaurantsCollection,
            data: restaurantData,
          );

          AppUtils.hideLoadingDialog();
          AppUtils.showSuccessSnackbar('Restaurant and owner account created successfully!\nOwner can now login with: ${emailController.text.trim()}');
        } catch (e) {
          AppUtils.hideLoadingDialog();

          // Provide specific error messages
          String errorMessage = 'Failed to create restaurant';
          if (e.toString().contains('email-already-in-use')) {
            errorMessage = 'An account with this email already exists. Please use a different email address.';
          } else if (e.toString().contains('weak-password')) {
            errorMessage = 'Password is too weak. Please choose a stronger password with at least ${AppConstants.minPasswordLength} characters.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Invalid email address. Please enter a valid email.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection and try again.';
          } else {
            errorMessage = 'Failed to create restaurant: ${e.toString()}';
          }

          AppUtils.showErrorSnackbar(errorMessage);
          return;
        }
      }
      
      if (restaurantId != null) {
        // Refresh the restaurant list in the background
        await loadRestaurants(refresh: true);

        // Clear the form for next entry but stay on the same page
        clearForm();

        // Don't navigate anywhere - stay on the current form page
        // This allows admin to add multiple restaurants without navigation
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save restaurant: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete restaurant
  Future<void> deleteRestaurant(RestaurantModel restaurant) async {
    final confirmed = await AppUtils.showConfirmationDialog(
      title: 'Delete Restaurant',
      message: 'Are you sure you want to delete "${restaurant.title}"? This action cannot be undone.',
      confirmText: 'Delete',
    );
    
    if (!confirmed) return;
    
    try {
      // Delete restaurant image
      if (restaurant.img.isNotEmpty) {
        await _storageService.deleteFile(restaurant.img);
      }
      
      // Delete restaurant document
      await _firestoreService.deleteDocument(
        collection: AppConstants.restaurantsCollection,
        docId: restaurant.id,
      );
      
      AppUtils.showSuccessSnackbar('Restaurant deleted successfully');
      await loadRestaurants(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete restaurant: $e');
    }
  }
  
  // Toggle restaurant status
  Future<void> toggleRestaurantStatus(RestaurantModel restaurant) async {
    try {
      final newStatus = restaurant.status == 'active' ? 'inactive' : 'active';
      
      await _firestoreService.updateDocument(
        collection: AppConstants.restaurantsCollection,
        docId: restaurant.id,
        data: {
          'status': newStatus,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('Restaurant status updated successfully');
      await loadRestaurants(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update restaurant status: $e');
    }
  }
  
  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!AppUtils.isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (!AppUtils.isValidPhone(value.trim())) {
      return 'Please enter a valid mobile number';
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
