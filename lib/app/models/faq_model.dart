import 'package:cloud_firestore/cloud_firestore.dart';

class FaqModel {
  final String id;
  final String question;
  final String answer;
  final String category; // 'general', 'restaurant', 'customer', 'payment', 'technical'
  final int order; // Display order
  final bool isActive;
  final String createdBy; // User ID who created this FAQ
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'general',
    this.order = 0,
    this.isActive = true,
    this.createdBy = '',
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory FaqModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FaqModel(
      id: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: data['category'] ?? 'general',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory FaqModel.fromMap(Map<String, dynamic> map) {
    return FaqModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'general',
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'] ?? '',
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
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  FaqModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'FaqModel(id: $id, question: $question, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FaqModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static methods for categories
  static List<String> get categories => [
    'general',
    'restaurant',
    'customer',
    'payment',
    'technical',
  ];

  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'general':
        return 'General';
      case 'restaurant':
        return 'Restaurant';
      case 'customer':
        return 'Customer';
      case 'payment':
        return 'Payment';
      case 'technical':
        return 'Technical';
      default:
        return 'General';
    }
  }
}
