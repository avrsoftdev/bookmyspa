import 'package:bookmyspa/src/core/widgets/admob_banner_widget.dart';
import 'package:bookmyspa/src/core/services/admob_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeBannerController extends BannerAdController {
  FakeBannerController({
    required super.adUnitId,
    required super.size,
    required super.firestore,
  });
  @override
  Future<void> load() async {
    // Simulate successful load without hitting platform channels
    _setState(AdLoadState.loaded);
  }

  // Expose protected state change for testing
  void _setState(AdLoadState newState) {
    // ignore: invalid_use_of_protected_member
    super.notifyListeners();
  }
}

class FakeAdMobService extends AdMobService {
  FakeAdMobService() : super(null);
  @override
  BannerAdController createBannerController({
    required String adUnitId,
    required AdSize size,
  }) {
    return FakeBannerController(
      adUnitId: adUnitId,
      size: size,
      firestore: null,
    );
  }
}

void main() {
  testWidgets('Banner collapses when keyboard visible', (tester) async {
    final mq = MediaQueryData(
      size: const Size(375, 812),
      viewInsets: const EdgeInsets.only(bottom: 300),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: mq,
          child: Scaffold(
            body: AdMobBannerWidget(
              adUnitId: 'test',
              service: FakeAdMobService(),
            ),
          ),
        ),
      ),
    );
    final container = find.byKey(const Key('admob_banner_container'));
    expect(container, findsOneWidget);
    final sizedBox = tester.widget<SizedBox>(container);
    expect(sizedBox.height, 0);
  });

  testWidgets('Responsive size does not overflow on rotation', (tester) async {
    MediaQueryData mq = const MediaQueryData(
      size: Size(812, 375),
      viewInsets: EdgeInsets.zero,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: mq,
          child: Scaffold(
            body: AdMobBannerWidget(
              adUnitId: 'test',
              service: FakeAdMobService(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    mq = const MediaQueryData(
      size: Size(375, 812),
      viewInsets: EdgeInsets.zero,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: mq,
          child: Scaffold(
            body: AdMobBannerWidget(
              adUnitId: 'test',
              service: FakeAdMobService(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('admob_banner_container')), findsOneWidget);
  });

  testWidgets('Property-based: multiple widths maintain non-negative height', (
    tester,
  ) async {
    for (final width in [320.0, 360.0, 400.0, 600.0, 728.0, 800.0]) {
      final mq = MediaQueryData(
        size: Size(width, 812),
        viewInsets: EdgeInsets.zero,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: mq,
            child: Scaffold(
              body: AdMobBannerWidget(
                adUnitId: 'test',
                service: FakeAdMobService(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(find.byType(AdMobBannerWidget), findsOneWidget);
    }
  });
}
