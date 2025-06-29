import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<StorageService>(StorageService(), permanent: true);

    // Initialize auth controller as permanent
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
