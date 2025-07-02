# Surprise Bag Order Integration Guide

This document explains how to integrate the surprise bag order system between your mobile app and the admin portal.

## Overview

The system allows customers to reserve surprise bags through the mobile app, and restaurants can manage these orders through the admin portal.

## Database Structure

### Collection: `surprise_bag_orders`

```javascript
{
  id: "auto-generated-id",
  userId: "customer-user-id",
  userName: "Customer Name",
  userEmail: "customer@email.com",
  userPhone: "+1234567890",
  surpriseBagId: "surprise-bag-id",
  surpriseBagTitle: "Surprise Bag Title",
  restaurantId: "restaurant-id",
  restaurantName: "Restaurant Name",
  originalPrice: 25.00,
  discountedPrice: 15.00,
  totalAmount: 15.00,
  quantity: 1,
  status: "pending", // pending, confirmed, ready, completed, cancelled
  paymentStatus: "paid", // pending, paid, refunded
  paymentMethod: "stripe", // stripe, paypal, etc.
  paymentId: "payment-transaction-id",
  pickupDate: "2024-01-15T00:00:00Z",
  pickupTimeSlot: "18:00-19:00",
  pickupInstructions: "Please come to the back entrance",
  customerNotes: "No nuts please",
  restaurantNotes: "Ready at counter",
  orderDate: "2024-01-14T10:30:00Z",
  confirmedAt: "2024-01-14T11:00:00Z",
  readyAt: "2024-01-15T18:00:00Z",
  completedAt: "2024-01-15T18:30:00Z",
  cancelledAt: null,
  cancellationReason: null,
  createdAt: "2024-01-14T10:30:00Z",
  updatedAt: "2024-01-15T18:30:00Z",
  additionalData: {}
}
```

## Mobile App Integration

### 1. Creating an Order (Mobile App)

When a customer reserves a surprise bag in your mobile app, create a document in the `surprise_bag_orders` collection:

```dart
// Example Flutter/Dart code for mobile app
Future<void> createSurpriseBagOrder({
  required String userId,
  required String userName,
  required String userEmail,
  required String userPhone,
  required String surpriseBagId,
  required String surpriseBagTitle,
  required String restaurantId,
  required String restaurantName,
  required double originalPrice,
  required double discountedPrice,
  required double totalAmount,
  required DateTime pickupDate,
  required String pickupTimeSlot,
  String? customerNotes,
  String? pickupInstructions,
}) async {
  final orderData = {
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
    'quantity': 1,
    'status': 'pending',
    'paymentStatus': 'pending', // Update to 'paid' after successful payment
    'paymentMethod': '',
    'paymentId': null,
    'pickupDate': Timestamp.fromDate(pickupDate),
    'pickupTimeSlot': pickupTimeSlot,
    'pickupInstructions': pickupInstructions ?? '',
    'customerNotes': customerNotes,
    'restaurantNotes': null,
    'orderDate': Timestamp.fromDate(DateTime.now()),
    'confirmedAt': null,
    'readyAt': null,
    'completedAt': null,
    'cancelledAt': null,
    'cancellationReason': null,
    'createdAt': Timestamp.fromDate(DateTime.now()),
    'updatedAt': Timestamp.fromDate(DateTime.now()),
    'additionalData': {},
  };

  await FirebaseFirestore.instance
      .collection('surprise_bag_orders')
      .add(orderData);
}
```

### 2. Update Payment Status (Mobile App)

After successful payment, update the order:

```dart
Future<void> updatePaymentStatus(String orderId, String paymentId, String paymentMethod) async {
  await FirebaseFirestore.instance
      .collection('surprise_bag_orders')
      .doc(orderId)
      .update({
    'paymentStatus': 'paid',
    'paymentId': paymentId,
    'paymentMethod': paymentMethod,
    'updatedAt': Timestamp.fromDate(DateTime.now()),
  });
}
```

### 3. Listen to Order Status Updates (Mobile App)

Listen for status changes to notify customers:

```dart
Stream<DocumentSnapshot> listenToOrderStatus(String orderId) {
  return FirebaseFirestore.instance
      .collection('surprise_bag_orders')
      .doc(orderId)
      .snapshots();
}

// Usage
listenToOrderStatus(orderId).listen((snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    final status = data['status'];
    final restaurantNotes = data['restaurantNotes'];
    
    // Show notification to user based on status
    switch (status) {
      case 'confirmed':
        showNotification('Order Confirmed', 'Your surprise bag has been confirmed!');
        break;
      case 'ready':
        showNotification('Ready for Pickup', 'Your surprise bag is ready! $restaurantNotes');
        break;
      case 'completed':
        showNotification('Order Completed', 'Thank you for picking up your surprise bag!');
        break;
      case 'cancelled':
        final reason = data['cancellationReason'];
        showNotification('Order Cancelled', 'Your order was cancelled: $reason');
        break;
    }
  }
});
```

## Admin Portal Features

The admin portal provides restaurants with:

### 1. Order Management Dashboard
- View all orders for their restaurant
- Filter by status, payment status, and date
- Search by customer name, email, or bag title
- Real-time statistics (total orders, pending, ready, revenue)

### 2. Order Status Management
- **Confirm Order**: Mark paid orders as confirmed
- **Mark Ready**: Indicate the bag is ready for pickup
- **Complete Order**: Mark as completed when customer picks up
- **Cancel Order**: Cancel with reason (triggers refund process)

### 3. Communication Features
- Add restaurant notes for customers
- Add pickup instructions
- View customer notes and special requests

### 4. Status Flow
```
pending (payment pending) → 
pending (payment completed) → 
confirmed (restaurant confirms) → 
ready (bag is prepared) → 
completed (customer picks up)

OR

cancelled (at any stage before completion)
```

## Notification Integration

### For Mobile App
Implement push notifications or in-app notifications when order status changes.

### For Admin Portal
The system includes placeholder methods for sending notifications to customers. You can integrate with:
- Firebase Cloud Messaging (FCM)
- Email services (SendGrid, AWS SES)
- SMS services (Twilio)

## Security Rules (Firestore)

Add these security rules to protect the data:

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Surprise bag orders
    match /surprise_bag_orders/{orderId} {
      // Customers can read their own orders
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      
      // Customers can create orders
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
      
      // Restaurant owners can read orders for their restaurant
      allow read: if request.auth != null && 
                     isRestaurantOwner(request.auth.uid, resource.data.restaurantId);
      
      // Restaurant owners can update order status and notes
      allow update: if request.auth != null && 
                       isRestaurantOwner(request.auth.uid, resource.data.restaurantId) &&
                       onlyUpdatingAllowedFields();
    }
    
    function isRestaurantOwner(userId, restaurantId) {
      return exists(/databases/$(database)/documents/restaurants/$(restaurantId)) &&
             get(/databases/$(database)/documents/restaurants/$(restaurantId)).data.ownerId == userId;
    }
    
    function onlyUpdatingAllowedFields() {
      let allowedFields = ['status', 'restaurantNotes', 'confirmedAt', 'readyAt', 
                          'completedAt', 'cancelledAt', 'cancellationReason', 'updatedAt'];
      return request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(allowedFields);
    }
  }
}
```

## Testing the Integration

1. **Create a test order** in your mobile app
2. **Check the admin portal** - the order should appear in the restaurant's order list
3. **Update the status** in the admin portal
4. **Verify notifications** are sent to the mobile app
5. **Test the complete flow** from order creation to completion

## Next Steps

1. Implement the order creation in your mobile app
2. Add payment integration and update payment status
3. Implement push notifications for status updates
4. Test the complete flow
5. Add any additional fields specific to your business needs

The admin portal is now ready to handle surprise bag orders from your mobile app!
