import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/spa_entity.dart';
import '../../domain/repositories/spa_repository.dart';

class SpaRepositoryImpl implements SpaRepository {
  final FirebaseFirestore firestore;

  SpaRepositoryImpl(this.firestore);

  @override
  Stream<List<SpaEntity>> streamApprovedByCategory(String category) {
    final normalized = category.trim();
    final synonyms = <String>{
      normalized,
      if (normalized == 'Skin Care') 'Facial',
      if (normalized == 'Therapy') 'Spa Therapy',
      if (normalized == 'Haircare') 'Hair Styling',
    }.toList();

    final query = firestore
        .collection('spas')
        .where('status', isEqualTo: 'approved')
        .where('services', arrayContainsAny: synonyms);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final ts = data['publishedAt'];
        DateTime? publishedAt;
        if (ts is Timestamp) {
          publishedAt = ts.toDate();
        }
        return SpaEntity(
          id: doc.id,
          businessName: data['businessName'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          services: List<String>.from((data['services'] as List?) ?? const []),
          pricing: ((data['pricing'] as List?) ?? const [])
              .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
              .toList(),
          photos: List<String>.from((data['photos'] as List?) ?? const []),
          status: data['status'] ?? '',
          publishedAt: publishedAt,
        );
      }).toList();
    });
  }

  @override
  Stream<SpaEntity?> streamSpaById(String id) {
    return firestore.collection('spas').doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      final ts = data['publishedAt'];
      DateTime? publishedAt;
      if (ts is Timestamp) {
        publishedAt = ts.toDate();
      }
      return SpaEntity(
        id: doc.id,
        businessName: data['businessName'] ?? '',
        city: data['city'] ?? '',
        description: data['description'] ?? '',
        fullAddress: data['fullAddress'] ?? '',
        services: List<String>.from((data['services'] as List?) ?? const []),
        pricing: ((data['pricing'] as List?) ?? const [])
            .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
            .toList(),
        photos: List<String>.from((data['photos'] as List?) ?? const []),
        status: data['status'] ?? '',
        publishedAt: publishedAt,
      );
    });
  }

  @override
  Stream<List<SpaEntity>> streamByOwnerUid(String ownerUid) {
    final query = firestore
        .collection('spas')
        .where('ownerUid', isEqualTo: ownerUid);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final ts = data['publishedAt'];
        DateTime? publishedAt;
        if (ts is Timestamp) {
          publishedAt = ts.toDate();
        }
        return SpaEntity(
          id: doc.id,
          businessName: data['businessName'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          services: List<String>.from((data['services'] as List?) ?? const []),
          pricing: ((data['pricing'] as List?) ?? const [])
              .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
              .toList(),
          photos: List<String>.from((data['photos'] as List?) ?? const []),
          status: data['status'] ?? '',
          publishedAt: publishedAt,
        );
      }).toList();
    });
  }
}
