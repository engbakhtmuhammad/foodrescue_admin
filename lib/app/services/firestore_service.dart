import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../utils/app_utils.dart';

class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Generic CRUD operations
  
  // Create document
  Future<String?> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
  }) async {
    try {
      DocumentReference docRef;
      
      if (docId != null) {
        docRef = _firestore.collection(collection).doc(docId);
        await docRef.set(data);
      } else {
        docRef = await _firestore.collection(collection).add(data);
      }
      
      return docRef.id;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to create document: $e');
      return null;
    }
  }
  
  // Read document
  Future<DocumentSnapshot?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to get document: $e');
      return null;
    }
  }
  
  // Update document
  Future<bool> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to update document: $e');
      return false;
    }
  }
  
  // Delete document
  Future<bool> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to delete document: $e');
      return false;
    }
  }
  
  // Get collection with pagination
  Future<QuerySnapshot?> getCollection({
    required String collection,
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to get collection: $e');
      print('Failed to get collection: $e');
      return null;
    }
  }
  
  // Get collection stream for real-time updates
  Stream<QuerySnapshot> getCollectionStream({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
    List<QueryFilter>? filters,
  }) {
    Query query = _firestore.collection(collection);
    
    // Apply filters
    if (filters != null) {
      for (final filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
    }
    
    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots();
  }
  
  // Get document stream for real-time updates
  Stream<DocumentSnapshot> getDocumentStream({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }
  
  // Batch operations
  Future<bool> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (final operation in operations) {
        final docRef = _firestore.collection(operation.collection).doc(operation.docId);
        
        switch (operation.type) {
          case BatchOperationType.create:
          case BatchOperationType.update:
            if (operation.data != null) {
              if (operation.type == BatchOperationType.create) {
                batch.set(docRef, operation.data!);
              } else {
                batch.update(docRef, operation.data!);
              }
            }
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to execute batch operation: $e');
      return false;
    }
  }
  
  // Search documents
  Future<QuerySnapshot?> searchDocuments({
    required String collection,
    required String field,
    required String searchTerm,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection)
          .where(field, isGreaterThanOrEqualTo: searchTerm)
          .where(field, isLessThanOrEqualTo: '$searchTerm\uf8ff');
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return await query.get();
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to search documents: $e');
      return null;
    }
  }
  
  // Count documents in collection
  Future<int> getDocumentCount({
    required String collection,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      
      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to count documents: $e');
      return 0;
    }
  }
  
  // Get aggregated data
  Future<Map<String, dynamic>?> getAggregatedData({
    required String collection,
    required String field,
    required AggregationType type,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        return {'result': 0, 'count': 0};
      }
      
      final values = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)[field])
          .where((value) => value is num)
          .cast<num>()
          .toList();
      
      if (values.isEmpty) {
        return {'result': 0, 'count': 0};
      }
      
      double result;
      switch (type) {
        case AggregationType.sum:
          result = values.fold(0.0, (sum, value) => sum + value).toDouble();
          break;
        case AggregationType.average:
          result = values.fold(0.0, (sum, value) => sum + value) / values.length;
          break;
        case AggregationType.max:
          result = values.reduce((a, b) => a > b ? a : b).toDouble();
          break;
        case AggregationType.min:
          result = values.reduce((a, b) => a < b ? a : b).toDouble();
          break;
      }
      
      return {'result': result, 'count': values.length};
    } catch (e) {
      AppUtils.showErrorSnackbar('Failed to get aggregated data: $e');
      return null;
    }
  }
}

// Helper classes
class QueryFilter {
  final String field;
  final dynamic value;
  
  QueryFilter({required this.field, required this.value});
}

class BatchOperation {
  final String collection;
  final String docId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;
  
  BatchOperation({
    required this.collection,
    required this.docId,
    required this.type,
    this.data,
  });
}

enum BatchOperationType { create, update, delete }

enum AggregationType { sum, average, max, min }
