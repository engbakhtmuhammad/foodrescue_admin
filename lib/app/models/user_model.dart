import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final String? ccode; // Country code
  final String? profileImage;
  final String role; // 'admin' or 'restaurant_owner' or 'customer'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.ccode,
    this.profileImage,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mobile: data['mobile'],
      ccode: data['ccode'],
      profileImage: data['profileImage'],
      role: data['role'] ?? 'customer',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: data['fcmToken'],
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'],
      ccode: map['ccode'],
      profileImage: map['profileImage'],
      role: map['role'] ?? 'customer',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      fcmToken: map['fcmToken'],
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include ID in the document data for easier queries
      'name': name,
      'email': email,
      'mobile': mobile,
      'ccode': ccode,
      'profileImage': profileImage,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'fcmToken': fcmToken,
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? ccode,
    String? profileImage,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      ccode: ccode ?? this.ccode,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
