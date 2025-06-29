import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../constants/app_constants.dart';
import '../models/faq_model.dart';
import '../utils/app_utils.dart';

class FaqController extends GetxController {
  static FaqController get instance => Get.find();
  
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable variables
  final isLoading = false.obs;
  final faqs = <FaqModel>[].obs;
  final filteredFaqs = <FaqModel>[].obs;
  final currentFaq = Rx<FaqModel?>(null);
  
  // Form controllers
  final questionController = TextEditingController();
  final answerController = TextEditingController();
  final orderController = TextEditingController();
  
  // Form variables
  final selectedCategory = 'general'.obs;
  final selectedIsActive = true.obs;
  
  // Search and filter
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedCategoryFilter = 'all'.obs;
  final selectedStatusFilter = 'all'.obs;
  
  // Form key
  final formKey = GlobalKey<FormState>();
  
  @override
  void onInit() {
    super.onInit();
    loadFaqs();
    
    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterFaqs();
    });
  }
  
  @override
  void onClose() {
    questionController.dispose();
    answerController.dispose();
    orderController.dispose();
    searchController.dispose();
    super.onClose();
  }
  
  // Load FAQs
  Future<void> loadFaqs({bool refresh = false}) async {
    if (refresh) {
      faqs.clear();
    }
    
    isLoading.value = true;
    
    try {
      final query = await _firestoreService.getCollection(
        collection: AppConstants.faqsCollection,
        orderBy: 'order',
        descending: false,
      );
      
      if (query != null) {
        faqs.value = query.docs
            .map((doc) => FaqModel.fromFirestore(doc))
            .toList();
      }
      
      _filterFaqs();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to load FAQs: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Filter FAQs
  void _filterFaqs() {
    var filtered = faqs.where((faq) {
      final matchesSearch = searchQuery.value.isEmpty ||
          faq.question.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          faq.answer.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      final matchesCategory = selectedCategoryFilter.value == 'all' ||
          faq.category == selectedCategoryFilter.value;
      
      final matchesStatus = selectedStatusFilter.value == 'all' ||
          (selectedStatusFilter.value == 'active' && faq.isActive) ||
          (selectedStatusFilter.value == 'inactive' && !faq.isActive);
      
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
    
    filteredFaqs.value = filtered;
  }
  
  // Clear form
  void clearForm() {
    questionController.clear();
    answerController.clear();
    orderController.clear();
    selectedCategory.value = 'general';
    selectedIsActive.value = true;
    currentFaq.value = null;
  }
  
  // Load FAQ for editing
  void loadFaqForEdit(FaqModel faq) {
    currentFaq.value = faq;
    questionController.text = faq.question;
    answerController.text = faq.answer;
    orderController.text = faq.order.toString();
    selectedCategory.value = faq.category;
    selectedIsActive.value = faq.isActive;
  }
  
  // Save FAQ
  Future<void> saveFaq() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    isLoading.value = true;
    
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        AppUtils.showErrorSnackbar('User not authenticated');
        return;
      }
      
      final now = DateTime.now();
      
      final faqData = {
        'question': questionController.text.trim(),
        'answer': answerController.text.trim(),
        'category': selectedCategory.value,
        'order': int.tryParse(orderController.text) ?? 0,
        'isActive': selectedIsActive.value,
        'createdBy': currentUser.id,
        'updatedAt': Timestamp.fromDate(now),
      };
      
      String? faqId;
      
      if (currentFaq.value != null) {
        // Update existing FAQ
        faqId = currentFaq.value!.id;
        await _firestoreService.updateDocument(
          collection: AppConstants.faqsCollection,
          docId: faqId,
          data: faqData,
        );
        AppUtils.showSuccessSnackbar('FAQ updated successfully');
      } else {
        // Create new FAQ
        faqData['createdAt'] = Timestamp.fromDate(now);
        faqId = await _firestoreService.createDocument(
          collection: AppConstants.faqsCollection,
          data: faqData,
        );
        AppUtils.showSuccessSnackbar('FAQ created successfully');
      }
      
      if (faqId != null) {
        await loadFaqs(refresh: true);
        clearForm();
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to save FAQ: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Delete FAQ
  Future<void> deleteFaq(FaqModel faq) async {
    try {
      await _firestoreService.deleteDocument(
        collection: AppConstants.faqsCollection,
        docId: faq.id,
      );
      
      AppUtils.showSuccessSnackbar('FAQ deleted successfully');
      await loadFaqs(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete FAQ: $e');
    }
  }
  
  // Toggle FAQ status
  Future<void> toggleFaqStatus(FaqModel faq) async {
    try {
      await _firestoreService.updateDocument(
        collection: AppConstants.faqsCollection,
        docId: faq.id,
        data: {
          'isActive': !faq.isActive,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      
      AppUtils.showSuccessSnackbar('FAQ status updated successfully');
      await loadFaqs(refresh: true);
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update FAQ status: $e');
    }
  }
  
  // Set category filter
  void setCategoryFilter(String category) {
    selectedCategoryFilter.value = category;
    _filterFaqs();
  }
  
  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _filterFaqs();
  }
  
  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Order is optional
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
}
