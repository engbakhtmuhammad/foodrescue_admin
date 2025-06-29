import 'package:cloud_firestore/cloud_firestore.dart';

class SurpriseBagModel {
  final String id;
  final String restaurantId; // Restaurant ID
  final String title;
  final String description;
  final String img;
  final double originalPrice;
  final double discountedPrice;
  final double discountPercentage;
  final int itemsLeft;
  final int totalItems;
  final String category; // e.g., 'Bakery', 'Meals', 'Groceries'
  final bool isAvailable;
  final String status; // 'active', 'inactive', 'sold_out'
  
  // Pickup Information
  final String pickupType; // 'today', 'tomorrow', 'both'
  final String todayPickupStart;
  final String todayPickupEnd;
  final String tomorrowPickupStart;
  final String tomorrowPickupEnd;
  final String pickupInstructions;
  
  // Location & Distance
  final double distance; // in kilometers
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  
  // Content Information
  final List<String> possibleItems; // What might be in the bag
  final List<String> allergens; // Allergen information
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final String dietaryInfo;
  
  // Ratings & Reviews
  final double rating;
  final int totalReviews;
  final int totalSold;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSoldAt;
  final Map<String, dynamic>? additionalData;

  SurpriseBagModel({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.img,
    required this.originalPrice,
    required this.discountedPrice,
    this.discountPercentage = 0.0,
    this.itemsLeft = 0,
    this.totalItems = 0,
    this.category = '',
    this.isAvailable = true,
    this.status = 'active',
    this.pickupType = 'today',
    this.todayPickupStart = '',
    this.todayPickupEnd = '',
    this.tomorrowPickupStart = '',
    this.tomorrowPickupEnd = '',
    this.pickupInstructions = '',
    this.distance = 0.0,
    this.pickupAddress = '',
    this.pickupLatitude = 0.0,
    this.pickupLongitude = 0.0,
    this.possibleItems = const [],
    this.allergens = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.dietaryInfo = '',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalSold = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastSoldAt,
    this.additionalData,
  });

  // Calculate discount percentage
  double get calculatedDiscountPercentage {
    if (originalPrice > 0) {
      return ((originalPrice - discountedPrice) / originalPrice) * 100;
    }
    return 0.0;
  }

  // Check if available for pickup today
  bool get isAvailableToday {
    return pickupType == 'today' || pickupType == 'both';
  }

  // Check if available for pickup tomorrow
  bool get isAvailableTomorrow {
    return pickupType == 'tomorrow' || pickupType == 'both';
  }

  // Get pickup time range for today
  String get todayPickupRange {
    if (todayPickupStart.isNotEmpty && todayPickupEnd.isNotEmpty) {
      return '$todayPickupStart - $todayPickupEnd';
    }
    return '';
  }

  // Get pickup time range for tomorrow
  String get tomorrowPickupRange {
    if (tomorrowPickupStart.isNotEmpty && tomorrowPickupEnd.isNotEmpty) {
      return '$tomorrowPickupStart - $tomorrowPickupEnd';
    }
    return '';
  }

  // Helper method to safely parse string lists
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    if (data is String) {
      return data.isEmpty ? [] : [data];
    }
    return [];
  }

  // Convert from Firestore Document
  factory SurpriseBagModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SurpriseBagModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0.0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
      itemsLeft: data['itemsLeft'] ?? 0,
      totalItems: data['totalItems'] ?? 0,
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      status: data['status'] ?? 'active',
      pickupType: data['pickupType'] ?? 'today',
      todayPickupStart: data['todayPickupStart'] ?? '',
      todayPickupEnd: data['todayPickupEnd'] ?? '',
      tomorrowPickupStart: data['tomorrowPickupStart'] ?? '',
      tomorrowPickupEnd: data['tomorrowPickupEnd'] ?? '',
      pickupInstructions: data['pickupInstructions'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      pickupAddress: data['pickupAddress'] ?? '',
      pickupLatitude: (data['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (data['pickupLongitude'] ?? 0.0).toDouble(),
      possibleItems: _parseStringList(data['possibleItems']),
      allergens: _parseStringList(data['allergens']),
      isVegetarian: data['isVegetarian'] ?? false,
      isVegan: data['isVegan'] ?? false,
      isGlutenFree: data['isGlutenFree'] ?? false,
      dietaryInfo: data['dietaryInfo'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      totalSold: data['totalSold'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSoldAt: (data['lastSoldAt'] as Timestamp?)?.toDate(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory SurpriseBagModel.fromMap(Map<String, dynamic> map) {
    return SurpriseBagModel(
      id: map['id'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      img: map['img'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0.0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      itemsLeft: map['itemsLeft'] ?? 0,
      totalItems: map['totalItems'] ?? 0,
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      status: map['status'] ?? 'active',
      pickupType: map['pickupType'] ?? 'today',
      todayPickupStart: map['todayPickupStart'] ?? '',
      todayPickupEnd: map['todayPickupEnd'] ?? '',
      tomorrowPickupStart: map['tomorrowPickupStart'] ?? '',
      tomorrowPickupEnd: map['tomorrowPickupEnd'] ?? '',
      pickupInstructions: map['pickupInstructions'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      pickupAddress: map['pickupAddress'] ?? '',
      pickupLatitude: (map['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (map['pickupLongitude'] ?? 0.0).toDouble(),
      possibleItems: _parseStringList(map['possibleItems']),
      allergens: _parseStringList(map['allergens']),
      isVegetarian: map['isVegetarian'] ?? false,
      isVegan: map['isVegan'] ?? false,
      isGlutenFree: map['isGlutenFree'] ?? false,
      dietaryInfo: map['dietaryInfo'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalSold: map['totalSold'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastSoldAt: map['lastSoldAt'] is Timestamp 
          ? (map['lastSoldAt'] as Timestamp).toDate()
          : null,
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'title': title,
      'description': description,
      'img': img,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'discountPercentage': calculatedDiscountPercentage,
      'itemsLeft': itemsLeft,
      'totalItems': totalItems,
      'category': category,
      'isAvailable': isAvailable,
      'status': status,
      'pickupType': pickupType,
      'todayPickupStart': todayPickupStart,
      'todayPickupEnd': todayPickupEnd,
      'tomorrowPickupStart': tomorrowPickupStart,
      'tomorrowPickupEnd': tomorrowPickupEnd,
      'pickupInstructions': pickupInstructions,
      'distance': distance,
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'possibleItems': possibleItems,
      'allergens': allergens,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'dietaryInfo': dietaryInfo,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalSold': totalSold,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSoldAt': lastSoldAt != null ? Timestamp.fromDate(lastSoldAt!) : null,
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  SurpriseBagModel copyWith({
    String? id,
    String? restaurantId,
    String? title,
    String? description,
    String? img,
    double? originalPrice,
    double? discountedPrice,
    double? discountPercentage,
    int? itemsLeft,
    int? totalItems,
    String? category,
    bool? isAvailable,
    String? status,
    String? pickupType,
    String? todayPickupStart,
    String? todayPickupEnd,
    String? tomorrowPickupStart,
    String? tomorrowPickupEnd,
    String? pickupInstructions,
    double? distance,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    List<String>? possibleItems,
    List<String>? allergens,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    String? dietaryInfo,
    double? rating,
    int? totalReviews,
    int? totalSold,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSoldAt,
    Map<String, dynamic>? additionalData,
  }) {
    return SurpriseBagModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      title: title ?? this.title,
      description: description ?? this.description,
      img: img ?? this.img,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      itemsLeft: itemsLeft ?? this.itemsLeft,
      totalItems: totalItems ?? this.totalItems,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      pickupType: pickupType ?? this.pickupType,
      todayPickupStart: todayPickupStart ?? this.todayPickupStart,
      todayPickupEnd: todayPickupEnd ?? this.todayPickupEnd,
      tomorrowPickupStart: tomorrowPickupStart ?? this.tomorrowPickupStart,
      tomorrowPickupEnd: tomorrowPickupEnd ?? this.tomorrowPickupEnd,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      distance: distance ?? this.distance,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      possibleItems: possibleItems ?? this.possibleItems,
      allergens: allergens ?? this.allergens,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalSold: totalSold ?? this.totalSold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSoldAt: lastSoldAt ?? this.lastSoldAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'SurpriseBagModel(id: $id, title: $title, originalPrice: $originalPrice, discountedPrice: $discountedPrice, itemsLeft: $itemsLeft)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurpriseBagModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
