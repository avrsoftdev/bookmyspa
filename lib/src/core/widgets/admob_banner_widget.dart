import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../di/di.dart';

class AdMobBannerWidget extends StatefulWidget {
  final String adUnitId;
  final AdMobService? service;
  const AdMobBannerWidget({super.key, required this.adUnitId, this.service});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget>
    with SingleTickerProviderStateMixin {
  BannerAdController? _controller;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = _sizeForContext();
    final svc = widget.service ?? sl.get<AdMobService>();
    if (!_initialized) {
      _controller = svc.createBannerController(
        adUnitId: widget.adUnitId,
        size: size,
      )..addListener(_onControllerChanged);
      _initialized = true;
      if (!_isKeyboardVisible()) {
        _controller!.load();
      }
    } else {
      final current = _controller;
      if (current != null && current.size != size) {
        current.disposeAd();
        _controller = svc.createBannerController(
          adUnitId: widget.adUnitId,
          size: size,
        )..addListener(_onControllerChanged);
        if (!_isKeyboardVisible()) {
          _controller!.load();
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _controller?.disposeAd();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  bool _isKeyboardVisible() {
    final insets = MediaQuery.of(context).viewInsets;
    return insets.bottom > 0;
  }

  AdSize _sizeForContext() {
    final mq = MediaQuery.of(context);
    final isPortrait = mq.orientation == Orientation.portrait;
    final width = mq.size.width.toInt();
    if (isPortrait) {
      return width >= 728 ? AdSize.leaderboard : AdSize.banner;
    } else {
      return width >= 728 ? AdSize.leaderboard : AdSize.fullBanner;
    }
  }

  double _heightForAdSize(AdSize size) {
    switch (size) {
      case AdSize.banner:
        return 50;
      case AdSize.fullBanner:
        return 60;
      case AdSize.leaderboard:
        return 90;
      default:
        return size.height.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final keyboardVisible = _isKeyboardVisible();
    final isLoaded =
        controller?.state == AdLoadState.loaded && controller?.ad != null;
    final targetHeight = (!keyboardVisible && isLoaded)
        ? _heightForAdSize(controller!.size)
        : 0.0;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: SizedBox(
        key: const Key('admob_banner_container'),
        height: targetHeight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoaded
              ? Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: kIsWeb
                      ? const SizedBox()
                      : AdWidget(ad: controller!.ad!),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
