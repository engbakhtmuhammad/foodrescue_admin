import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String pid; // Restaurant ID
  final String title;
  final String description;
  final String img;
  final double price;
  final String category;
  final bool isVeg;
  final bool isAvailable;
  final int preparationTime; // in minutes
  final List<String> ingredients;
  final Map<String, dynamic>? nutritionInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  MenuModel({
    required this.id,
    required this.pid,
    required this.title,
    required this.description,
    required this.img,
    required this.price,
    this.category = '',
    this.isVeg = true,
    this.isAvailable = true,
    this.preparationTime = 15,
    this.ingredients = const [],
    this.nutritionInfo,
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
  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuModel(
      id: doc.id,
      pid: data['pid'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      isVeg: data['isVeg'] ?? true,
      isAvailable: data['isAvailable'] ?? true,
      preparationTime: data['preparationTime'] ?? 15,
      ingredients: _parseStringList(data['ingredients']),
      nutritionInfo: data['nutritionInfo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] ?? '',
      pid: map['pid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      img: map['img'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      isVeg: map['isVeg'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
      preparationTime: map['preparationTime'] ?? 15,
      ingredients: _parseStringList(map['ingredients']),
      nutritionInfo: map['nutritionInfo'],
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
      'img': img,
      'price': price,
      'category': category,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
      'ingredients': ingredients,
      'nutritionInfo': nutritionInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  MenuModel copyWith({
    String? id,
    String? pid,
    String? title,
    String? description,
    String? img,
    double? price,
    String? category,
    bool? isVeg,
    bool? isAvailable,
    int? preparationTime,
    List<String>? ingredients,
    Map<String, dynamic>? nutritionInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return MenuModel(
      id: id ?? this.id,
      pid: pid ?? this.pid,
      title: title ?? this.title,
      description: description ?? this.description,
      img: img ?? this.img,
      price: price ?? this.price,
      category: category ?? this.category,
      isVeg: isVeg ?? this.isVeg,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'MenuModel(id: $id, title: $title, price: $price, category: $category, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
