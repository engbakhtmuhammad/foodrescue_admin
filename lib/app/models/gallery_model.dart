import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryModel {
  final String id;
  final String pid; // Restaurant ID
  final String catId; // Gallery Category ID
  final String img;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  GalleryModel({
    required this.id,
    required this.pid,
    required this.catId,
    required this.img,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory GalleryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryModel(
      id: doc.id,
      pid: data['pid'] ?? '',
      catId: data['catId'] ?? '',
      img: data['img'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory GalleryModel.fromMap(Map<String, dynamic> map) {
    return GalleryModel(
      id: map['id'] ?? '',
      pid: map['pid'] ?? '',
      catId: map['catId'] ?? '',
      img: map['img'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
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
      'pid': pid,
      'catId': catId,
      'img': img,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  GalleryModel copyWith({
    String? id,
    String? pid,
    String? catId,
    String? img,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return GalleryModel(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      catId: catId ?? this.catId,
      img: img ?? this.img,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'GalleryModel(id: $id, title: $title, pid: $pid, catId: $catId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class GalleryCategoryModel {
  final String id;
  final String pid; // Restaurant ID
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  GalleryCategoryModel({
    required this.id,
    required this.pid,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory GalleryCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GalleryCategoryModel(
      id: doc.id,
      pid: data['pid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory GalleryCategoryModel.fromMap(Map<String, dynamic> map) {
    return GalleryCategoryModel(
      id: map['id'] ?? '',
      pid: map['pid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
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
      'pid': pid,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  GalleryCategoryModel copyWith({
    String? id,
    String? pid,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return GalleryCategoryModel(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'GalleryCategoryModel(id: $id, title: $title, pid: $pid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryCategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
