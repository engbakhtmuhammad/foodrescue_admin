import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String uid; // User ID
  final String restId; // Restaurant ID
  final String customerName;
  final String customerEmail;
  final String customerMobile;
  final DateTime bookingDate;
  final String bookingTime;
  final int numberOfGuests;
  final String specialRequests;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  BookingModel({
    required this.id,
    required this.uid,
    required this.restId,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobile,
    required this.bookingDate,
    required this.bookingTime,
    required this.numberOfGuests,
    this.specialRequests = '',
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  // Convert from Firestore Document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      restId: data['restId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerMobile: data['customerMobile'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookingTime: data['bookingTime'] ?? '',
      numberOfGuests: data['numberOfGuests'] ?? 1,
      specialRequests: data['specialRequests'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalData: data['additionalData'],
    );
  }

  // Convert from Map
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      restId: map['restId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      bookingDate: map['bookingDate'] is Timestamp 
          ? (map['bookingDate'] as Timestamp).toDate()
          : DateTime.parse(map['bookingDate'] ?? DateTime.now().toIso8601String()),
      bookingTime: map['bookingTime'] ?? '',
      numberOfGuests: map['numberOfGuests'] ?? 1,
      specialRequests: map['specialRequests'] ?? '',
      status: map['status'] ?? 'pending',
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
      'uid': uid,
      'restId': restId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerMobile': customerMobile,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingTime': bookingTime,
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalData': additionalData,
    };
  }

  // Copy with method for updates
  BookingModel copyWith({
    String? id,
    String? uid,
    String? restId,
    String? customerName,
    String? customerEmail,
    String? customerMobile,
    DateTime? bookingDate,
    String? bookingTime,
    int? numberOfGuests,
    String? specialRequests,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return BookingModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      restId: restId ?? this.restId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerMobile: customerMobile ?? this.customerMobile,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, customerName: $customerName, restId: $restId, status: $status, bookingDate: $bookingDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Static methods for status and time slots
  static List<String> get statuses => [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
    'no_show',
  ];

  static List<String> get timeSlots => [
    '11:00-12:00',
    '12:00-13:00',
    '13:00-14:00',
    '14:00-15:00',
    '17:00-18:00',
    '18:00-19:00',
    '19:00-20:00',
    '20:00-21:00',
    '21:00-22:00',
  ];

  static String getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'no_show':
        return 'No Show';
      default:
        return 'Unknown';
    }
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isNoShow => status == 'no_show';

  bool get canBeConfirmed => status == 'pending';
  bool get canBeCancelled => status == 'pending' || status == 'confirmed';
  bool get canBeCompleted => status == 'confirmed';
  bool get canBeMarkedNoShow => status == 'confirmed' && bookingDate.isBefore(DateTime.now());
}
