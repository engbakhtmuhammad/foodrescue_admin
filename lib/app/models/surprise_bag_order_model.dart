import 'package:cloud_firestore/cloud_firestore.dart';

class SurpriseBagOrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String surpriseBagId;
  final String surpriseBagTitle;
  final String restaurantId;
  final String restaurantName;
  final double originalPrice;
  final double discountedPrice;
  final double totalAmount;
  final int quantity;
  final String status; // 'pending', 'confirmed', 'ready', 'completed', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final String paymentMethod;
  final String? paymentId;
  final DateTime pickupDate;
  final String pickupTimeSlot;
  final String pickupInstructions;
  final String? customerNotes;
  final String? restaurantNotes;
  final DateTime orderDate;
  final DateTime? confirmedAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  SurpriseBagOrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.surpriseBagId,
    required this.surpriseBagTitle,
    required this.restaurantId,
    required this.restaurantName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalAmount,
    this.quantity = 1,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = '',
    this.paymentId,
    required this.pickupDate,
    required this.pickupTimeSlot,
    this.pickupInstructions = '',
    this.customerNotes,
    this.restaurantNotes,
    required this.orderDate,
    this.confirmedAt,
    this.readyAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Static list of available statuses
  static const List<String> statuses = [
    'pending',
    'confirmed',
    'ready',
    'completed',
    'cancelled',
  ];

  // Static list of payment statuses
  static const List<String> paymentStatuses = [
    'pending',
    'paid',
    'refunded',
  ];

  // Get display name for status
  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Confirmation';
      case 'confirmed':
        return 'Confirmed';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  // Get display name for payment status
  static String getPaymentStatusDisplayName(String paymentStatus) {
    switch (paymentStatus) {
      case 'pending':
        return 'Payment Pending';
      case 'paid':
        return 'Paid';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus.toUpperCase();
    }
  }

  // Status check methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isReady => status == 'ready';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Payment status check methods
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isRefunded => paymentStatus == 'refunded';

  // Action availability checks
  bool get canBeConfirmed => status == 'pending' && isPaid;
  bool get canBeMarkedReady => status == 'confirmed';
  bool get canBeCompleted => status == 'ready';
  bool get canBeCancelled => status == 'pending' || status == 'confirmed';

  // Check if pickup time has passed
  bool get isPickupTimePassed {
    final now = DateTime.now();
    return pickupDate.isBefore(now);
  }

  // Convert from Firestore Document
  factory SurpriseBagOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SurpriseBagOrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
      surpriseBagId: data['surpriseBagId'] ?? '',
      surpriseBagTitle: data['surpriseBagTitle'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      originalPrice: (data['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (data['discountedPrice'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentId: data['paymentId'],
      pickupDate: (data['pickupDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupTimeSlot: data['pickupTimeSlot'] ?? '',
      pickupInstructions: data['pickupInstructions'] ?? '',
      customerNotes: data['customerNotes'],
      restaurantNotes: data['restaurantNotes'],
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      readyAt: (data['readyAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory SurpriseBagOrderModel.fromMap(Map<String, dynamic> map) {
    return SurpriseBagOrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      surpriseBagId: map['surpriseBagId'] ?? '',
      surpriseBagTitle: map['surpriseBagTitle'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentId: map['paymentId'],
      pickupDate: map['pickupDate'] is Timestamp 
          ? (map['pickupDate'] as Timestamp).toDate()
          : DateTime.parse(map['pickupDate'] ?? DateTime.now().toIso8601String()),
      pickupTimeSlot: map['pickupTimeSlot'] ?? '',
      pickupInstructions: map['pickupInstructions'] ?? '',
      customerNotes: map['customerNotes'],
      restaurantNotes: map['restaurantNotes'],
      orderDate: map['orderDate'] is Timestamp 
          ? (map['orderDate'] as Timestamp).toDate()
          : DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      confirmedAt: map['confirmedAt'] is Timestamp 
          ? (map['confirmedAt'] as Timestamp).toDate()
          : (map['confirmedAt'] != null ? DateTime.parse(map['confirmedAt']) : null),
      readyAt: map['readyAt'] is Timestamp 
          ? (map['readyAt'] as Timestamp).toDate()
          : (map['readyAt'] != null ? DateTime.parse(map['readyAt']) : null),
      completedAt: map['completedAt'] is Timestamp 
          ? (map['completedAt'] as Timestamp).toDate()
          : (map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null),
      cancelledAt: map['cancelledAt'] is Timestamp 
          ? (map['cancelledAt'] as Timestamp).toDate()
          : (map['cancelledAt'] != null ? DateTime.parse(map['cancelledAt']) : null),
      cancellationReason: map['cancellationReason'],
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
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'surpriseBagId': surpriseBagId,
      'surpriseBagTitle': surpriseBagTitle,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'totalAmount': totalAmount,
      'quantity': quantity,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'pickupTimeSlot': pickupTimeSlot,
      'pickupInstructions': pickupInstructions,
      'customerNotes': customerNotes,
      'restaurantNotes': restaurantNotes,
      'orderDate': Timestamp.fromDate(orderDate),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  SurpriseBagOrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? surpriseBagId,
    String? surpriseBagTitle,
    String? restaurantId,
    String? restaurantName,
    double? originalPrice,
    double? discountedPrice,
    double? totalAmount,
    int? quantity,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    DateTime? pickupDate,
    String? pickupTimeSlot,
    String? pickupInstructions,
    String? customerNotes,
    String? restaurantNotes,
    DateTime? orderDate,
    DateTime? confirmedAt,
    DateTime? readyAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return SurpriseBagOrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      surpriseBagId: surpriseBagId ?? this.surpriseBagId,
      surpriseBagTitle: surpriseBagTitle ?? this.surpriseBagTitle,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      customerNotes: customerNotes ?? this.customerNotes,
      restaurantNotes: restaurantNotes ?? this.restaurantNotes,
      orderDate: orderDate ?? this.orderDate,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      readyAt: readyAt ?? this.readyAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurpriseBagOrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
