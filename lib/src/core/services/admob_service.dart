import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AdLoadState { idle, loading, loaded, failed }

class BannerAdController extends ChangeNotifier {
  final String adUnitId;
  final AdSize size;
  final FirebaseFirestore? firestore;
  BannerAd? _ad;
  AdLoadState _state = AdLoadState.idle;

  BannerAdController({
    required this.adUnitId,
    required this.size,
    required this.firestore,
  });

  BannerAd? get ad => _ad;
  AdLoadState get state => _state;

  Future<void> load() async {
    if (_state == AdLoadState.loading || _state == AdLoadState.loaded) return;
    _setState(AdLoadState.loading);
    final banner = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _ad = ad as BannerAd;
          _logEvent('banner_loaded', {
            'adUnitId': adUnitId,
            'size': size.toString(),
          });
          _setState(AdLoadState.loaded);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _logEvent('banner_failed', {
            'adUnitId': adUnitId,
            'code': error.code,
            'domain': error.domain,
            'message': error.message,
          });
          _setState(AdLoadState.failed);
        },
        onAdImpression: (ad) {
          _logEvent('banner_impression', {'adUnitId': adUnitId});
        },
        onAdClicked: (ad) {
          _logEvent('banner_clicked', {'adUnitId': adUnitId});
        },
        onPaidEvent: (ad, valueMicros, currencyCode, precision) {
          _logEvent('banner_paid', {
            'adUnitId': adUnitId,
            'valueMicros': valueMicros,
            'currencyCode': currencyCode,
            'precision': precision,
          });
        },
      ),
    );
    try {
      await banner.load();
    } catch (e) {
      _logEvent('banner_load_exception', {
        'adUnitId': adUnitId,
        'error': e.toString(),
      });
      _setState(AdLoadState.failed);
    }
  }

  void disposeAd() {
    _ad?.dispose();
    _ad = null;
    _setState(AdLoadState.idle);
  }

  void _setState(AdLoadState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _logEvent(String type, Map<String, Object?> payload) async {
    try {
      final fs = firestore;
      if (fs == null) return;
      await fs.collection('ad_events').add({
        'type': type,
        'platform': defaultTargetPlatform.name,
        'ts': DateTime.now().toUtc().toIso8601String(),
        ...payload,
      });
    } catch (_) {}
  }
}

class AdMobService {
  final FirebaseFirestore? firestore;
  AdMobService(this.firestore);

  Future<InitializationStatus> initialize() async {
    final status = await MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      ),
    );
    return status;
  }

  BannerAdController createBannerController({
    required String adUnitId,
    required AdSize size,
  }) {
    return BannerAdController(
      adUnitId: adUnitId,
      size: size,
      firestore: firestore,
    );
  }
}
