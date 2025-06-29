import 'package:cloud_firestore/cloud_firestore.dart';

class CuisineModel {
  final String id;
  final String title;
  final String img;
  final String status; // 'active' or 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  CuisineModel({
    required this.id,
    required this.title,
    required this.img,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory CuisineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CuisineModel(
      id: doc.id,
      title: data['title'] ?? '',
      img: data['img'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory CuisineModel.fromMap(Map<String, dynamic> map) {
    return CuisineModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      img: map['img'] ?? '',
      status: map['status'] ?? 'active',
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  CuisineModel copyWith({
    String? id,
    String? title,
    String? img,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return CuisineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      img: img ?? this.img,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'CuisineModel(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CuisineModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
