import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantOwnerEmail;
  final double amount;
  final double commissionAmount;
  final double netAmount; // amount - commissionAmount
  final String currency;
  final String status; // 'pending', 'processing', 'completed', 'failed', 'cancelled'
  final String paymentMethod; // 'bank_transfer', 'paypal', 'stripe', 'manual'
  final String? transactionId;
  final String? bankAccountDetails;
  final String? paypalEmail;
  final String? notes;
  final String? failureReason;
  final DateTime periodStart; // Payout period start
  final DateTime periodEnd; // Payout period end
  final DateTime requestedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String requestedBy; // Admin user ID who requested the payout
  final String? processedBy; // Admin user ID who processed the payout
  final Map<String, dynamic>? additionalData;

  PayoutModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantOwnerEmail,
    required this.amount,
    this.commissionAmount = 0.0,
    required this.netAmount,
    this.currency = 'USD',
    this.status = 'pending',
    this.paymentMethod = 'bank_transfer',
    this.transactionId,
    this.bankAccountDetails,
    this.paypalEmail,
    this.notes,
    this.failureReason,
    required this.periodStart,
    required this.periodEnd,
    required this.requestedAt,
    this.processedAt,
    this.completedAt,
    required this.requestedBy,
    this.processedBy,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory PayoutModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PayoutModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      restaurantOwnerEmail: data['restaurantOwnerEmail'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      commissionAmount: (data['commissionAmount'] ?? 0.0).toDouble(),
      netAmount: (data['netAmount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'bank_transfer',
      transactionId: data['transactionId'],
      bankAccountDetails: data['bankAccountDetails'],
      paypalEmail: data['paypalEmail'],
      notes: data['notes'],
      failureReason: data['failureReason'],
      periodStart: (data['periodStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodEnd: (data['periodEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      requestedBy: data['requestedBy'] ?? '',
      processedBy: data['processedBy'],
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory PayoutModel.fromMap(Map<String, dynamic> map) {
    return PayoutModel(
      id: map['id'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      restaurantOwnerEmail: map['restaurantOwnerEmail'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      commissionAmount: (map['commissionAmount'] ?? 0.0).toDouble(),
      netAmount: (map['netAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'bank_transfer',
      transactionId: map['transactionId'],
      bankAccountDetails: map['bankAccountDetails'],
      paypalEmail: map['paypalEmail'],
      notes: map['notes'],
      failureReason: map['failureReason'],
      periodStart: map['periodStart'] is Timestamp 
          ? (map['periodStart'] as Timestamp).toDate()
          : DateTime.parse(map['periodStart'] ?? DateTime.now().toIso8601String()),
      periodEnd: map['periodEnd'] is Timestamp 
          ? (map['periodEnd'] as Timestamp).toDate()
          : DateTime.parse(map['periodEnd'] ?? DateTime.now().toIso8601String()),
      requestedAt: map['requestedAt'] is Timestamp 
          ? (map['requestedAt'] as Timestamp).toDate()
          : DateTime.parse(map['requestedAt'] ?? DateTime.now().toIso8601String()),
      processedAt: map['processedAt'] is Timestamp 
          ? (map['processedAt'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] is Timestamp 
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      requestedBy: map['requestedBy'] ?? '',
      processedBy: map['processedBy'],
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantOwnerEmail': restaurantOwnerEmail,
      'amount': amount,
      'commissionAmount': commissionAmount,
      'netAmount': netAmount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'bankAccountDetails': bankAccountDetails,
      'paypalEmail': paypalEmail,
      'notes': notes,
      'failureReason': failureReason,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'requestedBy': requestedBy,
      'processedBy': processedBy,
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  PayoutModel copyWith({
    String? id,
    String? restaurantId,
    String? restaurantName,
    String? restaurantOwnerEmail,
    double? amount,
    double? commissionAmount,
    double? netAmount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? transactionId,
    String? bankAccountDetails,
    String? paypalEmail,
    String? notes,
    String? failureReason,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? requestedAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? requestedBy,
    String? processedBy,
    Map<String, dynamic>? additionalData,
  }) {
    return PayoutModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantOwnerEmail: restaurantOwnerEmail ?? this.restaurantOwnerEmail,
      amount: amount ?? this.amount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      netAmount: netAmount ?? this.netAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      bankAccountDetails: bankAccountDetails ?? this.bankAccountDetails,
      paypalEmail: paypalEmail ?? this.paypalEmail,
      notes: notes ?? this.notes,
      failureReason: failureReason ?? this.failureReason,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      requestedBy: requestedBy ?? this.requestedBy,
      processedBy: processedBy ?? this.processedBy,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'PayoutModel(id: $id, restaurantName: $restaurantName, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayoutModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static methods for status and payment methods
  static List<String> get statuses => [
    'pending',
    'processing',
    'completed',
    'failed',
    'cancelled',
  ];

  static List<String> get paymentMethods => [
    'bank_transfer',
    'paypal',
    'stripe',
    'manual',
  ];

  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  static String getPaymentMethodDisplayName(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'manual':
        return 'Manual';
      default:
        return 'Unknown';
    }
  }
}
