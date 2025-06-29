import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentGatewayModel {
  final String id;
  final String name;
  final String type; // 'stripe', 'paypal', 'razorpay', 'square', 'manual'
  final String description;
  final bool isActive;
  final bool isDefault;
  final Map<String, dynamic> configuration; // Gateway-specific config
  final List<String> supportedCurrencies;
  final double transactionFeePercentage;
  final double fixedTransactionFee;
  final String? logoUrl;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  PaymentGatewayModel({
    required this.id,
    required this.name,
    required this.type,
    this.description = '',
    this.isActive = true,
    this.isDefault = false,
    this.configuration = const {},
    this.supportedCurrencies = const ['USD'],
    this.transactionFeePercentage = 0.0,
    this.fixedTransactionFee = 0.0,
    this.logoUrl,
    this.displayOrder = 0,
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
  factory PaymentGatewayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentGatewayModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
      configuration: Map<String, dynamic>.from(data['configuration'] ?? {}),
      supportedCurrencies: _parseStringList(data['supportedCurrencies']).isEmpty
          ? ['USD']
          : _parseStringList(data['supportedCurrencies']),
      transactionFeePercentage: (data['transactionFeePercentage'] ?? 0.0).toDouble(),
      fixedTransactionFee: (data['fixedTransactionFee'] ?? 0.0).toDouble(),
      logoUrl: data['logoUrl'],
      displayOrder: data['displayOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory PaymentGatewayModel.fromMap(Map<String, dynamic> map) {
    return PaymentGatewayModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      isDefault: map['isDefault'] ?? false,
      configuration: Map<String, dynamic>.from(map['configuration'] ?? {}),
      supportedCurrencies: _parseStringList(map['supportedCurrencies']).isEmpty
          ? ['USD']
          : _parseStringList(map['supportedCurrencies']),
      transactionFeePercentage: (map['transactionFeePercentage'] ?? 0.0).toDouble(),
      fixedTransactionFee: (map['fixedTransactionFee'] ?? 0.0).toDouble(),
      logoUrl: map['logoUrl'],
      displayOrder: map['displayOrder'] ?? 0,
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
      'name': name,
      'type': type,
      'description': description,
      'isActive': isActive,
      'isDefault': isDefault,
      'configuration': configuration,
      'supportedCurrencies': supportedCurrencies,
      'transactionFeePercentage': transactionFeePercentage,
      'fixedTransactionFee': fixedTransactionFee,
      'logoUrl': logoUrl,
      'displayOrder': displayOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  PaymentGatewayModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    bool? isActive,
    bool? isDefault,
    Map<String, dynamic>? configuration,
    List<String>? supportedCurrencies,
    double? transactionFeePercentage,
    double? fixedTransactionFee,
    String? logoUrl,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return PaymentGatewayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      configuration: configuration ?? this.configuration,
      supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
      transactionFeePercentage: transactionFeePercentage ?? this.transactionFeePercentage,
      fixedTransactionFee: fixedTransactionFee ?? this.fixedTransactionFee,
      logoUrl: logoUrl ?? this.logoUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'PaymentGatewayModel(id: $id, name: $name, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentGatewayModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static methods for gateway types
  static List<String> get gatewayTypes => [
    'stripe',
    'paypal',
    'razorpay',
    'square',
    'manual',
  ];

  static List<String> get supportedCurrenciesList => [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'INR',
  ];

  static String getGatewayTypeDisplayName(String type) {
    switch (type) {
      case 'stripe':
        return 'Stripe';
      case 'paypal':
        return 'PayPal';
      case 'razorpay':
        return 'Razorpay';
      case 'square':
        return 'Square';
      case 'manual':
        return 'Manual';
      default:
        return 'Unknown';
    }
  }

  // Get required configuration fields for each gateway type
  static List<String> getRequiredConfigFields(String type) {
    switch (type) {
      case 'stripe':
        return ['publishable_key', 'secret_key'];
      case 'paypal':
        return ['client_id', 'client_secret'];
      case 'razorpay':
        return ['key_id', 'key_secret'];
      case 'square':
        return ['application_id', 'access_token'];
      case 'manual':
        return [];
      default:
        return [];
    }
  }

  // Get configuration field display names
  static String getConfigFieldDisplayName(String field) {
    switch (field) {
      case 'publishable_key':
        return 'Publishable Key';
      case 'secret_key':
        return 'Secret Key';
      case 'client_id':
        return 'Client ID';
      case 'client_secret':
        return 'Client Secret';
      case 'key_id':
        return 'Key ID';
      case 'key_secret':
        return 'Key Secret';
      case 'application_id':
        return 'Application ID';
      case 'access_token':
        return 'Access Token';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
  }
}
