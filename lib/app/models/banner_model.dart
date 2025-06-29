import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String img;
  final String? link;
  final String status; // 'active' or 'inactive'
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  BannerModel({
    required this.id,
    required this.title,
    required this.img,
    this.link,
    this.status = 'active',
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      img: data['img'] ?? '',
      link: data['link'],
      status: data['status'] ?? 'active',
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      img: map['img'] ?? '',
      link: map['link'],
      status: map['status'] ?? 'active',
      sortOrder: map['sortOrder'] ?? 0,
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
      'link': link,
      'status': status,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  BannerModel copyWith({
    String? id,
    String? title,
    String? img,
    String? link,
    String? status,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      img: img ?? this.img,
      link: link ?? this.link,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BannerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
