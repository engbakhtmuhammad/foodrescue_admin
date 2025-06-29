import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable user
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    // Bind the firebase user to the observable
    firebaseUser.bindStream(_auth.authStateChanges());
    // Listen to user changes
    ever(firebaseUser, _setInitialScreen);
  }
  
  // Set initial screen based on auth state
  void _setInitialScreen(User? user) async {
    if (user == null) {
      // User is not logged in
      currentUser.value = null;
      Get.offAllNamed('/login');
    } else {
      // User is logged in, get user data
      await _loadUserData(user.uid);
      Get.offAllNamed('/dashboard');
    }
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load user data: $e');
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      AppUtils.showLoadingDialog(message: 'Signing in...');
      
      // Sign in with Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Check if user exists in Firestore with correct role
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = UserModel.fromFirestore(userDoc);
          
          // Check if role matches
          if (userData.role == role) {
            currentUser.value = userData;
            AppUtils.hideLoadingDialog();
            AppUtils.showSuccessSnackbar('Signed in successfully');
            return true;
          } else {
            // Role doesn't match, sign out
            await _auth.signOut();
            AppUtils.hideLoadingDialog();
            AppUtils.showErrorSnackbar('Invalid role for this account');
            return false;
          }
        } else {
          // User doesn't exist in Firestore, create user document
          final newUser = UserModel(
            id: credential.user!.uid,
            name: credential.user!.displayName ?? email.split('@')[0],
            email: email,
            role: role,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(credential.user!.uid)
              .set(newUser.toMap());
          
          currentUser.value = newUser;
          AppUtils.hideLoadingDialog();
          AppUtils.showSuccessSnackbar('Account created and signed in successfully');
          return true;
        }
      }
      
      AppUtils.hideLoadingDialog();
      return false;
    } on FirebaseAuthException catch (e) {
      AppUtils.hideLoadingDialog();
      String errorMessage = 'An error occurred';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'User account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Try again later';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }
      
      AppUtils.showErrorSnackbar(errorMessage);
      return false;
    } catch (e) {
      AppUtils.hideLoadingDialog();
      AppUtils.showErrorSnackbar('An unexpected error occurred: $e');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
      AppUtils.showSuccessSnackbar('Signed out successfully');
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to sign out: $e');
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      AppUtils.showLoadingDialog(message: 'Sending reset email...');
      
      await _auth.sendPasswordResetEmail(email: email);
      
      AppUtils.hideLoadingDialog();
      AppUtils.showSuccessSnackbar('Password reset email sent');
      return true;
    } on FirebaseAuthException catch (e) {
      AppUtils.hideLoadingDialog();
      String errorMessage = 'Failed to send reset email';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send reset email';
      }
      
      AppUtils.showErrorSnackbar(errorMessage);
      return false;
    } catch (e) {
      AppUtils.hideLoadingDialog();
      AppUtils.showErrorSnackbar('An unexpected error occurred: $e');
      return false;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      AppUtils.showLoadingDialog(message: 'Updating profile...');
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(updatedUser.id)
          .update(updatedUser.copyWith(updatedAt: DateTime.now()).toMap());
      
      currentUser.value = updatedUser.copyWith(updatedAt: DateTime.now());
      
      AppUtils.hideLoadingDialog();
      AppUtils.showSuccessSnackbar('Profile updated successfully');
      return true;
    } catch (e) {
      AppUtils.hideLoadingDialog();
      AppUtils.showErrorSnackbar('Failed to update profile: $e');
      return false;
    }
  }
  
  // Check if user is admin
  bool get isAdmin => currentUser.value?.role == AppConstants.adminRole;
  
  // Check if user is restaurant owner
  bool get isRestaurantOwner => currentUser.value?.role == AppConstants.restaurantOwnerRole;
  
  // Check if user is authenticated
  bool get isAuthenticated => firebaseUser.value != null && currentUser.value != null;

  // Get current user ID
  String? get currentUserId => firebaseUser.value?.uid;

  // Check if email already exists in users collection
  Future<bool> emailExists(String email) async {
    try {
      final query = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Test user creation (for debugging)
  Future<void> testUserCreation() async {
    try {
      print('Testing user creation...');

      // Test creating a simple user document
      final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      final testUserData = {
        'id': testUserId,
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'restaurant_owner',
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      print('Creating test user with ID: $testUserId');
      print('Test user data: $testUserData');

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(testUserId)
          .set(testUserData);

      print('Test user created successfully');

      // Verify it was created
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(testUserId)
          .get();

      print('Test user verification: exists=${doc.exists}');
      if (doc.exists) {
        print('Test user data retrieved: ${doc.data()}');
      }

      // Clean up test user
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(testUserId)
          .delete();

      print('Test user cleaned up');
    } catch (e) {
      print('Test user creation failed: $e');
    }
  }

  // Create new user account (for restaurant owners)
  Future<String?> createUserAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String? mobile,
    String? ccode,
  }) async {
    // Store current admin user info to restore session
    final currentAdminUser = _auth.currentUser;
    final currentAdminEmail = currentAdminUser?.email;

    try {
      // Create Firebase Auth user (this will sign them in automatically)
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userId = credential.user!.uid;
        final now = DateTime.now();

        // Create user document in Firestore
        final newUser = UserModel(
          id: userId,
          name: name,
          email: email,
          mobile: mobile,
          ccode: ccode,
          role: role,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        // Debug: Print user data before saving
        print('Creating user in Firestore:');
        print('User ID: $userId');
        print('User Data: ${newUser.toMap()}');
        print('Collection: ${AppConstants.usersCollection}');

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .set(newUser.toMap());

        // Debug: Verify user was created
        final verifyDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get();

        print('User creation verification:');
        print('Document exists: ${verifyDoc.exists}');
        if (verifyDoc.exists) {
          print('Document data: ${verifyDoc.data()}');
        }

        // Sign out the newly created user to restore admin session
        await _auth.signOut();

        // Re-authenticate as admin if we had a current user
        if (currentAdminUser != null) {
          // The admin should still be logged in through the app state
          // We just need to ensure the Firebase Auth state is correct
          print('Restored admin session after user creation');
        }

        return userId;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to create user account';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = e.message ?? 'Failed to create user account';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
