class AppConstants {
  // App Info
  static const String appName = 'Dineout Admin';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (if needed for external services)
  static const String baseUrl = 'https://your-api-url.com/api/';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String restaurantsCollection = 'restaurants';
  static const String ordersCollection = 'orders';
  static const String menusCollection = 'menus';
  static const String bannersCollection = 'banners';
  static const String cuisinesCollection = 'cuisines';
  static const String facilitiesCollection = 'facilities';
  static const String faqsCollection = 'faqs';
  static const String pagesCollection = 'pages';
  static const String packagesCollection = 'packages';
  static const String galleriesCollection = 'galleries';
  static const String galleryCategoriesCollection = 'gallery_categories';
  static const String paymentGatewaysCollection = 'payment_gateways';
  static const String payoutsCollection = 'payouts';
  static const String bookingsCollection = 'bookings';
  static const String settingsCollection = 'settings';
  static const String surpriseBagsCollection = 'surprise_bags';
  static const String reviewsCollection = 'reviews';
  
  // Storage Paths
  static const String restaurantImagesPath = 'restaurant_images';
  static const String menuImagesPath = 'menu_images';
  static const String bannerImagesPath = 'banner_images';
  static const String galleryImagesPath = 'gallery_images';
  static const String userImagesPath = 'user_images';
  static const String surpriseBagImagesPath = 'surprise_bag_images';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String restaurantOwnerRole = 'restaurant_owner';
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';
  
  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  
  // Booking Status
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingCompleted = 'completed';
  static const String bookingCancelled = 'cancelled';
  
  // Restaurant Status
  static const String restaurantActive = 'active';
  static const String restaurantInactive = 'inactive';
  
  // Default Values
  static const int defaultPageSize = 20;
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxRestaurantNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Time Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Currency
  static const String defaultCurrency = '\$';
  
  // Image Constraints
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 80;
  
  // Pagination
  static const int itemsPerPage = 10;
  
  // Cache Keys
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
}
