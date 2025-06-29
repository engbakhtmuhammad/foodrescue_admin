import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String title;
  final String img;
  final String status; // 'active' or 'inactive'
  final bool tShow; // Table booking show
  final double rating;
  final int totalReviews;
  final double averageRating;
  final Map<String, int> ratingBreakdown; // e.g., {'5': 10, '4': 5, '3': 2, '2': 1, '1': 0}
  final double approxPrice;
  final String openTime;
  final String closeTime;
  final String? certificateCode;
  final String mobile;
  final String shortDescription;
  final String email;
  final String password;
  final List<String> cuisines; // Cuisine IDs
  final List<String> facilities; // Facility IDs
  final String fullAddress;
  final String pincode;
  final String area;
  final double latitude;
  final double longitude;
  final double showRadius;
  final String popularDishes;
  final String mondayThursdayOffer;
  final String mondayThursdayOfferDesc;
  final String fridaySundayOffer;
  final String fridaySundayOfferDesc;
  final String ownerId; // User ID of restaurant owner
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  RestaurantModel({
    required this.id,
    required this.title,
    required this.img,
    this.status = 'active',
    this.tShow = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.ratingBreakdown = const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    this.approxPrice = 0.0,
    required this.openTime,
    required this.closeTime,
    this.certificateCode,
    required this.mobile,
    required this.shortDescription,
    required this.email,
    required this.password,
    this.cuisines = const [],
    this.facilities = const [],
    required this.fullAddress,
    required this.pincode,
    required this.area,
    required this.latitude,
    required this.longitude,
    this.showRadius = 5.0,
    this.popularDishes = '',
    this.mondayThursdayOffer = '',
    this.mondayThursdayOfferDesc = '',
    this.fridaySundayOffer = '',
    this.fridaySundayOfferDesc = '',
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

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

  // Helper method to safely parse rating breakdown map
  static Map<String, int> _parseRatingBreakdown(dynamic data) {
    if (data == null) return {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    if (data is Map) {
      final result = <String, int>{};
      data.forEach((key, value) {
        result[key.toString()] = (value is int) ? value : int.tryParse(value.toString()) ?? 0;
      });
      // Ensure all rating keys exist
      for (String rating in ['5', '4', '3', '2', '1']) {
        result[rating] ??= 0;
      }
      return result;
    }
    return {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
  }

  // Helper method to safely parse string fields that might be stored as lists
  static String _parseStringField(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is List) {
      return data.map((item) => item.toString()).join(', ');
    }
    return data.toString();
  }

  // Convert from Firestore Document
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      id: doc.id,
      title: _parseStringField(data['title']),
      img: _parseStringField(data['img']),
      status: _parseStringField(data['status']).isEmpty ? 'active' : _parseStringField(data['status']),
      tShow: data['tShow'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingBreakdown: _parseRatingBreakdown(data['ratingBreakdown']),
      approxPrice: (data['approxPrice'] ?? 0.0).toDouble(),
      openTime: _parseStringField(data['openTime']),
      closeTime: _parseStringField(data['closeTime']),
      certificateCode: data['certificateCode'] != null ? _parseStringField(data['certificateCode']) : null,
      mobile: _parseStringField(data['mobile']),
      shortDescription: _parseStringField(data['shortDescription']),
      email: _parseStringField(data['email']),
      password: _parseStringField(data['password']),
      cuisines: _parseStringList(data['cuisines']),
      facilities: _parseStringList(data['facilities']),
      fullAddress: _parseStringField(data['fullAddress']),
      pincode: _parseStringField(data['pincode']),
      area: _parseStringField(data['area']),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      showRadius: (data['showRadius'] ?? 5.0).toDouble(),
      popularDishes: _parseStringField(data['popularDishes']),
      mondayThursdayOffer: _parseStringField(data['mondayThursdayOffer']),
      mondayThursdayOfferDesc: _parseStringField(data['mondayThursdayOfferDesc']),
      fridaySundayOffer: _parseStringField(data['fridaySundayOffer']),
      fridaySundayOfferDesc: _parseStringField(data['fridaySundayOfferDesc']),
      ownerId: _parseStringField(data['ownerId']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] ?? '',
      title: _parseStringField(map['title']),
      img: _parseStringField(map['img']),
      status: _parseStringField(map['status']).isEmpty ? 'active' : _parseStringField(map['status']),
      tShow: map['tShow'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      ratingBreakdown: _parseRatingBreakdown(map['ratingBreakdown']),
      approxPrice: (map['approxPrice'] ?? 0.0).toDouble(),
      openTime: _parseStringField(map['openTime']),
      closeTime: _parseStringField(map['closeTime']),
      certificateCode: map['certificateCode'] != null ? _parseStringField(map['certificateCode']) : null,
      mobile: _parseStringField(map['mobile']),
      shortDescription: _parseStringField(map['shortDescription']),
      email: _parseStringField(map['email']),
      password: _parseStringField(map['password']),
      cuisines: _parseStringList(map['cuisines']),
      facilities: _parseStringList(map['facilities']),
      fullAddress: _parseStringField(map['fullAddress']),
      pincode: _parseStringField(map['pincode']),
      area: _parseStringField(map['area']),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      showRadius: (map['showRadius'] ?? 5.0).toDouble(),
      popularDishes: _parseStringField(map['popularDishes']),
      mondayThursdayOffer: _parseStringField(map['mondayThursdayOffer']),
      mondayThursdayOfferDesc: _parseStringField(map['mondayThursdayOfferDesc']),
      fridaySundayOffer: _parseStringField(map['fridaySundayOffer']),
      fridaySundayOfferDesc: _parseStringField(map['fridaySundayOfferDesc']),
      ownerId: _parseStringField(map['ownerId']),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'img': img,
      'status': status,
      'tShow': tShow,
      'rating': rating,
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'ratingBreakdown': ratingBreakdown,
      'approxPrice': approxPrice,
      'openTime': openTime,
      'closeTime': closeTime,
      'certificateCode': certificateCode,
      'mobile': mobile,
      'shortDescription': shortDescription,
      'email': email,
      'password': password,
      'cuisines': cuisines,
      'facilities': facilities,
      'fullAddress': fullAddress,
      'pincode': pincode,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'showRadius': showRadius,
      'popularDishes': popularDishes,
      'mondayThursdayOffer': mondayThursdayOffer,
      'mondayThursdayOfferDesc': mondayThursdayOfferDesc,
      'fridaySundayOffer': fridaySundayOffer,
      'fridaySundayOfferDesc': fridaySundayOfferDesc,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  RestaurantModel copyWith({
    String? id,
    String? title,
    String? img,
    String? status,
    bool? tShow,
    double? rating,
    int? totalReviews,
    double? averageRating,
    Map<String, int>? ratingBreakdown,
    double? approxPrice,
    String? openTime,
    String? closeTime,
    String? certificateCode,
    String? mobile,
    String? shortDescription,
    String? email,
    String? password,
    List<String>? cuisines,
    List<String>? facilities,
    String? fullAddress,
    String? pincode,
    String? area,
    double? latitude,
    double? longitude,
    double? showRadius,
    String? popularDishes,
    String? mondayThursdayOffer,
    String? mondayThursdayOfferDesc,
    String? fridaySundayOffer,
    String? fridaySundayOfferDesc,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      title: title ?? this.title,
      img: img ?? this.img,
      status: status ?? this.status,
      tShow: tShow ?? this.tShow,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      averageRating: averageRating ?? this.averageRating,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      approxPrice: approxPrice ?? this.approxPrice,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      certificateCode: certificateCode ?? this.certificateCode,
      mobile: mobile ?? this.mobile,
      shortDescription: shortDescription ?? this.shortDescription,
      email: email ?? this.email,
      password: password ?? this.password,
      cuisines: cuisines ?? this.cuisines,
      facilities: facilities ?? this.facilities,
      fullAddress: fullAddress ?? this.fullAddress,
      pincode: pincode ?? this.pincode,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      showRadius: showRadius ?? this.showRadius,
      popularDishes: popularDishes ?? this.popularDishes,
      mondayThursdayOffer: mondayThursdayOffer ?? this.mondayThursdayOffer,
      mondayThursdayOfferDesc: mondayThursdayOfferDesc ?? this.mondayThursdayOfferDesc,
      fridaySundayOffer: fridaySundayOffer ?? this.fridaySundayOffer,
      fridaySundayOfferDesc: fridaySundayOfferDesc ?? this.fridaySundayOfferDesc,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'RestaurantModel(id: $id, title: $title, status: $status, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
