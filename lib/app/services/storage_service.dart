import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_utils.dart';

class StorageService extends GetxService {
  static StorageService get instance => Get.find();
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Upload file from path
  Future<String?> uploadFile({
    required String filePath,
    required String storagePath,
    String? fileName,
  }) async {
    try {
      AppUtils.showLoadingDialog(message: 'Uploading file...');
      
      final file = File(filePath);
      if (!file.existsSync()) {
        AppUtils.hideLoadingDialog();
        AppUtils.showErrorSnackbar('File does not exist');
        return null;
      }
      
      // Validate file size
      final fileSize = await file.length();
      if (!AppUtils.isValidImageSize(fileSize)) {
        AppUtils.hideLoadingDialog();
        AppUtils.showErrorSnackbar('File size too large. Maximum 5MB allowed.');
        return null;
      }
      
      // Generate filename if not provided
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      final ref = _storage.ref().child('$storagePath/$fileName');
      final uploadTask = ref.putFile(file);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppUtils.hideLoadingDialog();
      AppUtils.showSuccessSnackbar('File uploaded successfully');
      return downloadUrl;
    } catch (e) {
      AppUtils.hideLoadingDialog();
      AppUtils.showErrorSnackbar('Failed to upload file: $e');
      return null;
    }
  }
  
  // Upload file from bytes (for web)
  Future<String?> uploadFileFromBytes({
    required Uint8List fileBytes,
    required String storagePath,
    required String fileName,
    String? contentType,
  }) async {
    try {
      AppUtils.showLoadingDialog(message: 'Uploading file...');
      
      // Validate file size
      if (!AppUtils.isValidImageSize(fileBytes.length)) {
        AppUtils.hideLoadingDialog();
        AppUtils.showErrorSnackbar('File size too large. Maximum 5MB allowed.');
        return null;
      }
      
      final ref = _storage.ref().child('$storagePath/$fileName');
      
      UploadTask uploadTask;
      if (contentType != null) {
        uploadTask = ref.putData(fileBytes, SettableMetadata(contentType: contentType));
      } else {
        uploadTask = ref.putData(fileBytes);
      }
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppUtils.hideLoadingDialog();
      AppUtils.showSuccessSnackbar('File uploaded successfully');
      return downloadUrl;
    } catch (e) {
      AppUtils.hideLoadingDialog();
      AppUtils.showErrorSnackbar('Failed to upload file: $e');
      return null;
    }
  }
  
  // Pick and upload image
  Future<String?> pickAndUploadImage({
    required String storagePath,
    ImageSource source = ImageSource.gallery,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return null;
      }

      // Validate file extension
      if (!AppUtils.isValidImageExtension(pickedFile.name)) {
        AppUtils.showErrorSnackbar('Invalid file format. Please select a valid image.');
        return null;
      }

      // For web, we need to use bytes instead of file path
      final Uint8List fileBytes = await pickedFile.readAsBytes();

      return await uploadFileFromBytes(
        fileBytes: fileBytes,
        storagePath: storagePath,
        fileName: pickedFile.name,
        contentType: 'image/${pickedFile.name.split('.').last}',
      );
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to pick and upload image: $e');
      return null;
    }
  }
  
  // Pick multiple images
  Future<List<String>> pickAndUploadMultipleImages({
    required String storagePath,
    int imageQuality = 80,
    int? maxImages,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: imageQuality,
      );
      
      if (pickedFiles.isEmpty) {
        return [];
      }
      
      // Limit number of images if specified
      final filesToUpload = maxImages != null && pickedFiles.length > maxImages
          ? pickedFiles.take(maxImages).toList()
          : pickedFiles;
      
      final List<String> uploadedUrls = [];
      
      for (final file in filesToUpload) {
        // Validate file extension
        if (!AppUtils.isValidImageExtension(file.name)) {
          AppUtils.showWarningSnackbar('Skipped ${file.name}: Invalid file format');
          continue;
        }
        
        // For web, we need to use bytes instead of file path
        final Uint8List fileBytes = await file.readAsBytes();

        final url = await uploadFileFromBytes(
          fileBytes: fileBytes,
          storagePath: storagePath,
          fileName: file.name,
          contentType: 'image/${file.name.split('.').last}',
        );
        
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
      
      return uploadedUrls;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to pick and upload images: $e');
      return [];
    }
  }
  
  // Delete file
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete file: $e');
      return false;
    }
  }
  
  // Delete multiple files
  Future<bool> deleteMultipleFiles(List<String> downloadUrls) async {
    try {
      for (final url in downloadUrls) {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      }
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete files: $e');
      return false;
    }
  }
  
  // Get file metadata
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to get file metadata: $e');
      return null;
    }
  }
  
  // Update file metadata
  Future<bool> updateFileMetadata({
    required String downloadUrl,
    required Map<String, String> customMetadata,
  }) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.updateMetadata(SettableMetadata(customMetadata: customMetadata));
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update file metadata: $e');
      return false;
    }
  }
  
  // Get download URL from storage path
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to get download URL: $e');
      return null;
    }
  }
  
  // List files in a directory
  Future<List<Reference>> listFiles(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to list files: $e');
      return [];
    }
  }
}
