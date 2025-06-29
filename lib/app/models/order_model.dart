import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String uid; // User ID
  final String restId; // Restaurant ID
  final double totalAmount;
  final double tipAmount;
  final double discountAmount;
  final double payedAmount;
  final double discountPercentage;
  final double walletAmount;
  final String paymentId; // Payment method ID
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final Map<String, dynamic>? additionalData;

  OrderModel({
    required this.id,
    required this.uid,
    required this.restId,
    required this.totalAmount,
    this.tipAmount = 0.0,
    this.discountAmount = 0.0,
    required this.payedAmount,
    this.discountPercentage = 0.0,
    this.walletAmount = 0.0,
    required this.paymentId,
    this.status = 'pending',
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.additionalData,
  });

  // Convert from Firestore Document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      restId: data['restId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      tipAmount: (data['tipAmount'] ?? 0.0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      payedAmount: (data['payedAmount'] ?? 0.0).toDouble(),
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
      walletAmount: (data['walletAmount'] ?? 0.0).toDouble(),
      paymentId: data['paymentId'] ?? '',
      status: data['status'] ?? 'pending',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      restId: map['restId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      tipAmount: (map['tipAmount'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      payedAmount: (map['payedAmount'] ?? 0.0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      walletAmount: (map['walletAmount'] ?? 0.0).toDouble(),
      paymentId: map['paymentId'] ?? '',
      status: map['status'] ?? 'pending',
      orderDate: map['orderDate'] is Timestamp 
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'restId': restId,
      'totalAmount': totalAmount,
      'tipAmount': tipAmount,
      'discountAmount': discountAmount,
      'payedAmount': payedAmount,
      'discountPercentage': discountPercentage,
      'walletAmount': walletAmount,
      'paymentId': paymentId,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'items': items.map((item) => item.toMap()).toList(),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  OrderModel copyWith({
    String? id,
    String? uid,
    String? restId,
    double? totalAmount,
    double? tipAmount,
    double? discountAmount,
    double? payedAmount,
    double? discountPercentage,
    double? walletAmount,
    String? paymentId,
    String? status,
    DateTime? orderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    Map<String, dynamic>? additionalData,
  }) {
    return OrderModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      restId: restId ?? this.restId,
      totalAmount: totalAmount ?? this.totalAmount,
      tipAmount: tipAmount ?? this.tipAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      payedAmount: payedAmount ?? this.payedAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      walletAmount: walletAmount ?? this.walletAmount,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, uid: $uid, restId: $restId, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class OrderItem {
  final String menuId;
  final String menuName;
  final double price;
  final int quantity;
  final String? notes;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.quantity,
    this.notes,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      menuId: map['menuId'] ?? '',
      menuName: map['menuName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'price': price,
      'quantity': quantity,
      'notes': notes,
    };
  }

  double get totalPrice => price * quantity;

  @override
  String toString() {
    return 'OrderItem(menuId: $menuId, menuName: $menuName, price: $price, quantity: $quantity)';
  }
}
