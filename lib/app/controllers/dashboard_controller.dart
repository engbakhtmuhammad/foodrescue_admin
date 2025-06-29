import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/banner_model.dart';
import '../models/cuisine_model.dart';
import '../models/facility_model.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables for dashboard stats
  final isLoading = false.obs;
  final totalBanners = 0.obs;
  final totalCuisines = 0.obs;
  final totalRestaurants = 0.obs;
  final totalFacilities = 0.obs;
  final totalFAQs = 0.obs;
  final totalPaymentGateways = 0.obs;
  final totalDynamicPages = 0.obs;
  final totalSubscriptionPlans = 0.obs;
  final totalUsers = 0.obs;
  final totalEarnings = 0.0.obs;
  final pendingPayouts = 0.0.obs;
  final completedPayouts = 0.0.obs;
  
  // Restaurant owner specific stats
  final restaurantGalleryCategories = 0.obs;
  final restaurantGalleries = 0.obs;
  final restaurantMenus = 0.obs;
  final restaurantSurpriseBags = 0.obs;
  final restaurantActiveSurpriseBags = 0.obs;
  final restaurantSoldSurpriseBags = 0.obs;
  final restaurantBookings = 0.obs;
  final restaurantOrders = 0.obs;
  final restaurantEarnings = 0.0.obs;
  final restaurantReceivedAmount = 0.0.obs;
  
  // Recent data
  final recentOrders = <OrderModel>[].obs;
  final recentUsers = <UserModel>[].obs;
  final recentRestaurants = <RestaurantModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }
  
  // Load dashboard data based on user role
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    
    try {
      if (_authService.isAdmin) {
        await _loadAdminDashboardData();
      } else if (_authService.isRestaurantOwner) {
        await _loadRestaurantOwnerDashboardData();
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load admin dashboard data
  Future<void> _loadAdminDashboardData() async {
    // Load counts for all collections
    await Future.wait([
      _loadBannersCount(),
      _loadCuisinesCount(),
      _loadRestaurantsCount(),
      _loadFacilitiesCount(),
      _loadFAQsCount(),
      _loadPaymentGatewaysCount(),
      _loadDynamicPagesCount(),
      _loadSubscriptionPlansCount(),
      _loadUsersCount(),
      _loadEarningsData(),
      _loadPayoutsData(),
      _loadRecentData(),
    ]);
  }
  
  // Load restaurant owner dashboard data
  Future<void> _loadRestaurantOwnerDashboardData() async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;
    
    // Find restaurant owned by current user
    final restaurantQuery = await _firestoreService.getCollection(
      collection: AppConstants.restaurantsCollection,
      filters: [QueryFilter(field: 'ownerId', value: currentUser.id)],
      limit: 1,
    );
    
    if (restaurantQuery?.docs.isNotEmpty == true) {
      final restaurantId = restaurantQuery!.docs.first.id;
      
      await Future.wait([
        _loadRestaurantSpecificData(restaurantId),
        _loadRestaurantEarningsData(restaurantId),
        _loadRecentRestaurantData(restaurantId),
      ]);
    }
  }
  
  // Load individual counts
  Future<void> _loadBannersCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.bannersCollection,
    );
    totalBanners.value = count;
  }
  
  Future<void> _loadCuisinesCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.cuisinesCollection,
    );
    totalCuisines.value = count;
  }
  
  Future<void> _loadRestaurantsCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.restaurantsCollection,
    );
    totalRestaurants.value = count;
  }
  
  Future<void> _loadFacilitiesCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.facilitiesCollection,
    );
    totalFacilities.value = count;
  }
  
  Future<void> _loadFAQsCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.faqsCollection,
    );
    totalFAQs.value = count;
  }
  
  Future<void> _loadPaymentGatewaysCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.paymentGatewaysCollection,
    );
    totalPaymentGateways.value = count;
  }
  
  Future<void> _loadDynamicPagesCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.pagesCollection,
    );
    totalDynamicPages.value = count;
  }
  
  Future<void> _loadSubscriptionPlansCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.packagesCollection,
    );
    totalSubscriptionPlans.value = count;
  }
  
  Future<void> _loadUsersCount() async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.usersCollection,
    );
    totalUsers.value = count;
  }
  
  // Load earnings data
  Future<void> _loadEarningsData() async {
    final earningsData = await _firestoreService.getAggregatedData(
      collection: AppConstants.ordersCollection,
      field: 'payedAmount',
      type: AggregationType.sum,
      filters: [QueryFilter(field: 'status', value: AppConstants.orderCompleted)],
    );
    
    if (earningsData != null) {
      totalEarnings.value = earningsData['result'] ?? 0.0;
    }
  }
  
  // Load payouts data
  Future<void> _loadPayoutsData() async {
    final pendingData = await _firestoreService.getAggregatedData(
      collection: AppConstants.payoutsCollection,
      field: 'amount',
      type: AggregationType.sum,
      filters: [QueryFilter(field: 'status', value: AppConstants.paymentPending)],
    );
    
    final completedData = await _firestoreService.getAggregatedData(
      collection: AppConstants.payoutsCollection,
      field: 'amount',
      type: AggregationType.sum,
      filters: [QueryFilter(field: 'status', value: AppConstants.paymentCompleted)],
    );
    
    if (pendingData != null) {
      pendingPayouts.value = pendingData['result'] ?? 0.0;
    }
    
    if (completedData != null) {
      completedPayouts.value = completedData['result'] ?? 0.0;
    }
  }
  
  // Load restaurant specific data
  Future<void> _loadRestaurantSpecificData(String restaurantId) async {
    await Future.wait([
      _loadRestaurantGalleryCategoriesCount(restaurantId),
      _loadRestaurantGalleriesCount(restaurantId),
      _loadRestaurantMenusCount(restaurantId),
      _loadRestaurantSurpriseBagsCount(restaurantId),
      _loadRestaurantBookingsCount(restaurantId),
      _loadRestaurantOrdersCount(restaurantId),
    ]);
  }
  
  Future<void> _loadRestaurantGalleryCategoriesCount(String restaurantId) async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.galleryCategoriesCollection,
      filters: [QueryFilter(field: 'pid', value: restaurantId)],
    );
    restaurantGalleryCategories.value = count;
  }
  
  Future<void> _loadRestaurantGalleriesCount(String restaurantId) async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.galleriesCollection,
      filters: [QueryFilter(field: 'pid', value: restaurantId)],
    );
    restaurantGalleries.value = count;
  }
  
  Future<void> _loadRestaurantMenusCount(String restaurantId) async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.menusCollection,
      filters: [QueryFilter(field: 'pid', value: restaurantId)],
    );
    restaurantMenus.value = count;
  }

  Future<void> _loadRestaurantSurpriseBagsCount(String restaurantId) async {
    // Total surprise bags
    final totalCount = await _firestoreService.getDocumentCount(
      collection: AppConstants.surpriseBagsCollection,
      filters: [QueryFilter(field: 'restaurantId', value: restaurantId)],
    );
    restaurantSurpriseBags.value = totalCount;

    // Active surprise bags
    final activeCount = await _firestoreService.getDocumentCount(
      collection: AppConstants.surpriseBagsCollection,
      filters: [
        QueryFilter(field: 'restaurantId', value: restaurantId),
        QueryFilter(field: 'status', value: 'active'),
        QueryFilter(field: 'isAvailable', value: true),
      ],
    );
    restaurantActiveSurpriseBags.value = activeCount;

    // Sold out surprise bags
    final soldOutCount = await _firestoreService.getDocumentCount(
      collection: AppConstants.surpriseBagsCollection,
      filters: [
        QueryFilter(field: 'restaurantId', value: restaurantId),
        QueryFilter(field: 'status', value: 'sold_out'),
      ],
    );
    restaurantSoldSurpriseBags.value = soldOutCount;
  }
  
  Future<void> _loadRestaurantBookingsCount(String restaurantId) async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.bookingsCollection,
      filters: [QueryFilter(field: 'restId', value: restaurantId)],
    );
    restaurantBookings.value = count;
  }
  
  Future<void> _loadRestaurantOrdersCount(String restaurantId) async {
    final count = await _firestoreService.getDocumentCount(
      collection: AppConstants.ordersCollection,
      filters: [QueryFilter(field: 'restId', value: restaurantId)],
    );
    restaurantOrders.value = count;
  }
  
  // Load restaurant earnings data
  Future<void> _loadRestaurantEarningsData(String restaurantId) async {
    final earningsData = await _firestoreService.getAggregatedData(
      collection: AppConstants.ordersCollection,
      field: 'payedAmount',
      type: AggregationType.sum,
      filters: [
        QueryFilter(field: 'restId', value: restaurantId),
        QueryFilter(field: 'status', value: AppConstants.orderCompleted),
      ],
    );
    
    final receivedData = await _firestoreService.getAggregatedData(
      collection: AppConstants.payoutsCollection,
      field: 'amount',
      type: AggregationType.sum,
      filters: [
        QueryFilter(field: 'ownerId', value: restaurantId),
        QueryFilter(field: 'status', value: AppConstants.paymentCompleted),
      ],
    );
    
    if (earningsData != null) {
      restaurantEarnings.value = earningsData['result'] ?? 0.0;
    }
    
    if (receivedData != null) {
      restaurantReceivedAmount.value = receivedData['result'] ?? 0.0;
    }
  }
  
  // Load recent data
  Future<void> _loadRecentData() async {
    // Load recent orders
    final ordersQuery = await _firestoreService.getCollection(
      collection: AppConstants.ordersCollection,
      orderBy: 'createdAt',
      descending: true,
      limit: 5,
    );
    
    if (ordersQuery != null) {
      recentOrders.value = ordersQuery.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    }
    
    // Load recent users
    final usersQuery = await _firestoreService.getCollection(
      collection: AppConstants.usersCollection,
      orderBy: 'createdAt',
      descending: true,
      limit: 5,
    );
    
    if (usersQuery != null) {
      recentUsers.value = usersQuery.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    }
    
    // Load recent restaurants
    final restaurantsQuery = await _firestoreService.getCollection(
      collection: AppConstants.restaurantsCollection,
      orderBy: 'createdAt',
      descending: true,
      limit: 5,
    );
    
    if (restaurantsQuery != null) {
      recentRestaurants.value = restaurantsQuery.docs
          .map((doc) => RestaurantModel.fromFirestore(doc))
          .toList();
    }
  }
  
  // Load recent restaurant data
  Future<void> _loadRecentRestaurantData(String restaurantId) async {
    // Load recent orders for this restaurant
    final ordersQuery = await _firestoreService.getCollection(
      collection: AppConstants.ordersCollection,
      filters: [QueryFilter(field: 'restId', value: restaurantId)],
      orderBy: 'createdAt',
      descending: true,
      limit: 5,
    );
    
    if (ordersQuery != null) {
      recentOrders.value = ordersQuery.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    }
  }
  
  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }
}
