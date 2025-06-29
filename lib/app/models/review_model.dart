import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId; // User who wrote the review
  final String restaurantId; // Restaurant being reviewed
  final String? surpriseBagId; // Optional: if review is for a specific surprise bag
  final double rating; // 1-5 stars
  final String title;
  final String comment;
  final List<String> images; // Review images
  final String reviewType; // 'restaurant', 'surprise_bag'
  
  // Review metadata
  final bool isVerifiedPurchase;
  final bool isRecommended;
  final int helpfulCount; // How many found this review helpful
  final int reportCount; // How many reported this review
  final String status; // 'active', 'hidden', 'reported'
  
  // Response from restaurant
  final String? restaurantResponse;
  final DateTime? restaurantResponseDate;
  final String? restaurantResponseBy; // User ID of restaurant owner/manager
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.surpriseBagId,
    required this.rating,
    this.title = '',
    required this.comment,
    this.images = const [],
    this.reviewType = 'restaurant',
    this.isVerifiedPurchase = false,
    this.isRecommended = true,
    this.helpfulCount = 0,
    this.reportCount = 0,
    this.status = 'active',
    this.restaurantResponse,
    this.restaurantResponseDate,
    this.restaurantResponseBy,
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

  // Convert from Firestore Document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      surpriseBagId: data['surpriseBagId'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      title: data['title'] ?? '',
      comment: data['comment'] ?? '',
      images: _parseStringList(data['images']),
      reviewType: data['reviewType'] ?? 'restaurant',
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
      isRecommended: data['isRecommended'] ?? true,
      helpfulCount: data['helpfulCount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      status: data['status'] ?? 'active',
      restaurantResponse: data['restaurantResponse'],
      restaurantResponseDate: (data['restaurantResponseDate'] as Timestamp?)?.toDate(),
      restaurantResponseBy: data['restaurantResponseBy'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      surpriseBagId: map['surpriseBagId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      title: map['title'] ?? '',
      comment: map['comment'] ?? '',
      images: _parseStringList(map['images']),
      reviewType: map['reviewType'] ?? 'restaurant',
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
      isRecommended: map['isRecommended'] ?? true,
      helpfulCount: map['helpfulCount'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
      status: map['status'] ?? 'active',
      restaurantResponse: map['restaurantResponse'],
      restaurantResponseDate: map['restaurantResponseDate'] is Timestamp 
          ? (map['restaurantResponseDate'] as Timestamp).toDate()
          : null,
      restaurantResponseBy: map['restaurantResponseBy'],
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
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'surpriseBagId': surpriseBagId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'reviewType': reviewType,
      'isVerifiedPurchase': isVerifiedPurchase,
      'isRecommended': isRecommended,
      'helpfulCount': helpfulCount,
      'reportCount': reportCount,
      'status': status,
      'restaurantResponse': restaurantResponse,
      'restaurantResponseDate': restaurantResponseDate != null 
          ? Timestamp.fromDate(restaurantResponseDate!) 
          : null,
      'restaurantResponseBy': restaurantResponseBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? surpriseBagId,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    String? reviewType,
    bool? isVerifiedPurchase,
    bool? isRecommended,
    int? helpfulCount,
    int? reportCount,
    String? status,
    String? restaurantResponse,
    DateTime? restaurantResponseDate,
    String? restaurantResponseBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      surpriseBagId: surpriseBagId ?? this.surpriseBagId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      reviewType: reviewType ?? this.reviewType,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      isRecommended: isRecommended ?? this.isRecommended,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      restaurantResponse: restaurantResponse ?? this.restaurantResponse,
      restaurantResponseDate: restaurantResponseDate ?? this.restaurantResponseDate,
      restaurantResponseBy: restaurantResponseBy ?? this.restaurantResponseBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, comment: $comment, restaurantId: $restaurantId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
