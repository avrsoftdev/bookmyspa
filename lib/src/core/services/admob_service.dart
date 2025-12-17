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
  int _retryCount = 0;
  Timer? _retryTimer;

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
          debugPrint('AdMob: banner_loaded $adUnitId size=$size');
          _logEvent('banner_loaded', {
            'adUnitId': adUnitId,
            'size': size.toString(),
          });
          _setState(AdLoadState.loaded);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
            'AdMob: banner_failed $adUnitId code=${error.code} domain=${error.domain} message=${error.message}',
          );
          _logEvent('banner_failed', {
            'adUnitId': adUnitId,
            'code': error.code,
            'domain': error.domain,
            'message': error.message,
          });
          _setState(AdLoadState.failed);
          if (error.code == 3) {
            _scheduleRetry();
          }
        },
        onAdImpression: (ad) {
          debugPrint('AdMob: banner_impression $adUnitId');
          _logEvent('banner_impression', {'adUnitId': adUnitId});
        },
        onAdClicked: (ad) {
          debugPrint('AdMob: banner_clicked $adUnitId');
          _logEvent('banner_clicked', {'adUnitId': adUnitId});
        },
        onPaidEvent: (ad, valueMicros, currencyCode, precision) {
          debugPrint(
            'AdMob: banner_paid $adUnitId valueMicros=$valueMicros currency=$currencyCode precision=$precision',
          );
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
    _retryTimer?.cancel();
    _ad?.dispose();
    _ad = null;
    _setState(AdLoadState.idle);
    _retryCount = 0;
  }

  void _setState(AdLoadState newState) {
    _state = newState;
    notifyListeners();
  }

  void _scheduleRetry() {
    if (_retryTimer != null) return;
    final delaySeconds = (10 * (1 << (_retryCount.clamp(0, 3)))).clamp(10, 60);
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      _retryTimer = null;
      _retryCount = (_retryCount + 1).clamp(0, 4);
      if (_state == AdLoadState.failed) {
        load();
      }
    });
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
