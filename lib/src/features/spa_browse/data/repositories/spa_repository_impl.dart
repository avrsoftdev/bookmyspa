import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/spa_entity.dart';
import '../../domain/repositories/spa_repository.dart';

class SpaRepositoryImpl implements SpaRepository {
  final FirebaseFirestore firestore;

  SpaRepositoryImpl(this.firestore);

  double? _parseRating(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }

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
        final latRaw = data['latitude'];
        final lngRaw = data['longitude'];
        final latitude = latRaw is num
            ? latRaw.toDouble()
            : double.tryParse(latRaw?.toString() ?? '');
        final longitude = lngRaw is num
            ? lngRaw.toDouble()
            : double.tryParse(lngRaw?.toString() ?? '');
        final rawDetails =
            (data['serviceDetails'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final parsedDetails = <String, ServiceDetail>{};
        for (final entry in rawDetails.entries) {
          final v =
              (entry.value as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          parsedDetails[entry.key] = ServiceDetail.fromMap(v);
        }
        return SpaEntity(
          id: doc.id,
          businessName: data['businessName'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          latitude: latitude,
          longitude: longitude,
          whatsappNumber: data['whatsappNumber']?.toString(),
          services: List<String>.from((data['services'] as List?) ?? const []),
          pricing: ((data['pricing'] as List?) ?? const [])
              .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
              .toList(),
          photos: List<String>.from((data['photos'] as List?) ?? const []),
          status: data['status'] ?? '',
          publishedAt: publishedAt,
          rating:
              _parseRating(data['rating']) ??
              _parseRating(data['averageRating']),
          serviceDetails: parsedDetails,
          openingTime: data['openingTime']?.toString(),
          closingTime: data['closingTime']?.toString(),
          maxBookingsPerHour: int.tryParse(
            data['maxBookingsPerHour']?.toString() ?? '',
          ),
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
      final latRaw = data['latitude'];
      final lngRaw = data['longitude'];
      final latitude = latRaw is num
          ? latRaw.toDouble()
          : double.tryParse(latRaw?.toString() ?? '');
      final longitude = lngRaw is num
          ? lngRaw.toDouble()
          : double.tryParse(lngRaw?.toString() ?? '');
      final rawDetails =
          (data['serviceDetails'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      final parsedDetails = <String, ServiceDetail>{};
      for (final entry in rawDetails.entries) {
        final v =
            (entry.value as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        parsedDetails[entry.key] = ServiceDetail.fromMap(v);
      }
      return SpaEntity(
        id: doc.id,
        businessName: data['businessName'] ?? '',
        city: data['city'] ?? '',
        description: data['description'] ?? '',
        fullAddress: data['fullAddress'] ?? '',
        latitude: latitude,
        longitude: longitude,
        whatsappNumber: data['whatsappNumber']?.toString(),
        services: List<String>.from((data['services'] as List?) ?? const []),
        pricing: ((data['pricing'] as List?) ?? const [])
            .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
            .toList(),
        photos: List<String>.from((data['photos'] as List?) ?? const []),
        status: data['status'] ?? '',
        publishedAt: publishedAt,
        rating:
            _parseRating(data['rating']) ?? _parseRating(data['averageRating']),
        serviceDetails: parsedDetails,
        openingTime: data['openingTime']?.toString(),
        closingTime: data['closingTime']?.toString(),
        maxBookingsPerHour: int.tryParse(
          data['maxBookingsPerHour']?.toString() ?? '',
        ),
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
        final latRaw = data['latitude'];
        final lngRaw = data['longitude'];
        final latitude = latRaw is num
            ? latRaw.toDouble()
            : double.tryParse(latRaw?.toString() ?? '');
        final longitude = lngRaw is num
            ? lngRaw.toDouble()
            : double.tryParse(lngRaw?.toString() ?? '');
        final rawDetails =
            (data['serviceDetails'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final parsedDetails = <String, ServiceDetail>{};
        for (final entry in rawDetails.entries) {
          final v =
              (entry.value as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          parsedDetails[entry.key] = ServiceDetail.fromMap(v);
        }
        return SpaEntity(
          id: doc.id,
          businessName: data['businessName'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          latitude: latitude,
          longitude: longitude,
          whatsappNumber: data['whatsappNumber']?.toString(),
          services: List<String>.from((data['services'] as List?) ?? const []),
          pricing: ((data['pricing'] as List?) ?? const [])
              .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
              .toList(),
          photos: List<String>.from((data['photos'] as List?) ?? const []),
          status: data['status'] ?? '',
          publishedAt: publishedAt,
          rating:
              _parseRating(data['rating']) ??
              _parseRating(data['averageRating']),
          serviceDetails: parsedDetails,
          openingTime: data['openingTime']?.toString(),
          closingTime: data['closingTime']?.toString(),
          maxBookingsPerHour: int.tryParse(
            data['maxBookingsPerHour']?.toString() ?? '',
          ),
        );
      }).toList();
    });
  }

  @override
  Stream<List<SpaEntity>> streamApprovedAll() {
    final query = firestore
        .collection('spas')
        .where('status', isEqualTo: 'approved');

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final ts = data['publishedAt'];
        DateTime? publishedAt;
        if (ts is Timestamp) {
          publishedAt = ts.toDate();
        }
        final latRaw = data['latitude'];
        final lngRaw = data['longitude'];
        final latitude = latRaw is num
            ? latRaw.toDouble()
            : double.tryParse(latRaw?.toString() ?? '');
        final longitude = lngRaw is num
            ? lngRaw.toDouble()
            : double.tryParse(lngRaw?.toString() ?? '');
        final rawDetails =
            (data['serviceDetails'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final parsedDetails = <String, ServiceDetail>{};
        for (final entry in rawDetails.entries) {
          final v =
              (entry.value as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          parsedDetails[entry.key] = ServiceDetail.fromMap(v);
        }
        return SpaEntity(
          id: doc.id,
          businessName: data['businessName'] ?? '',
          city: data['city'] ?? '',
          description: data['description'] ?? '',
          fullAddress: data['fullAddress'] ?? '',
          latitude: latitude,
          longitude: longitude,
          whatsappNumber: data['whatsappNumber']?.toString(),
          services: List<String>.from((data['services'] as List?) ?? const []),
          pricing: ((data['pricing'] as List?) ?? const [])
              .map((e) => ServicePricing.fromMap(e as Map<String, dynamic>))
              .toList(),
          photos: List<String>.from((data['photos'] as List?) ?? const []),
          status: data['status'] ?? '',
          publishedAt: publishedAt,
          rating:
              _parseRating(data['rating']) ??
              _parseRating(data['averageRating']),
          serviceDetails: parsedDetails,
        );
      }).toList();
    });
  }
}
