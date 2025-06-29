import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // Create admin user with Firebase Auth
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'admin@foodrescue.com',
      password: 'admin123456',
    );

    final User? user = userCredential.user;
    if (user != null) {
      // Add user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'id': user.uid,
        'name': 'Admin User',
        'email': 'admin@foodrescue.com',
        'phone': '+1234567890',
        'role': 'admin',
        'status': 'active',
        'profileImage': '',
        'address': 'Admin Address',
        'city': 'Admin City',
        'state': 'Admin State',
        'country': 'Admin Country',
        'zipCode': '12345',
        'dateOfBirth': null,
        'gender': 'other',
        'isEmailVerified': true,
        'isPhoneVerified': false,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Admin user created successfully!');
      print('📧 Email: admin@foodrescue.com');
      print('🔑 Password: admin123456');
      print('👤 Role: admin');
      print('🆔 User ID: ${user.uid}');
    }
  } catch (e) {
    print('❌ Error creating admin user: $e');
    
    // If user already exists, just print the credentials
    if (e.toString().contains('email-already-in-use')) {
      print('ℹ️  Admin user already exists!');
      print('📧 Email: admin@foodrescue.com');
      print('🔑 Password: admin123456');
    }
  }

  // Also create a restaurant owner for testing
  try {
    final UserCredential ownerCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: 'owner@restaurant.com',
      password: 'owner123456',
    );

    final User? owner = ownerCredential.user;
    if (owner != null) {
      // Add owner data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(owner.uid)
          .set({
        'id': owner.uid,
        'name': 'Restaurant Owner',
        'email': 'owner@restaurant.com',
        'phone': '+1234567891',
        'role': 'restaurant_owner',
        'status': 'active',
        'profileImage': '',
        'address': 'Restaurant Address',
        'city': 'Restaurant City',
        'state': 'Restaurant State',
        'country': 'Restaurant Country',
        'zipCode': '12346',
        'dateOfBirth': null,
        'gender': 'other',
        'isEmailVerified': true,
        'isPhoneVerified': false,
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ Restaurant owner created successfully!');
      print('📧 Email: owner@restaurant.com');
      print('🔑 Password: owner123456');
      print('👤 Role: restaurant_owner');
      print('🆔 User ID: ${owner.uid}');
    }
  } catch (e) {
    print('❌ Error creating restaurant owner: $e');
    
    if (e.toString().contains('email-already-in-use')) {
      print('ℹ️  Restaurant owner already exists!');
      print('📧 Email: owner@restaurant.com');
      print('🔑 Password: owner123456');
    }
  }

  print('\n🎉 Setup complete! You can now login with either account.');
}
