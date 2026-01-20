import 'package:app_links/app_links.dart';

class DeepLinkService {
  Future<String?> getInitialSpaId() async {
    try {
      final appLinks = AppLinks();
      final deepLink = await appLinks.getInitialAppLink();
      if (deepLink == null) return null;
      final qpId = deepLink.queryParameters['spaId'];
      if (qpId != null && qpId.isNotEmpty) return qpId;
      final extracted = _extractSpaIdFromPath(deepLink);
      return extracted;
    } catch (_) {
      return null;
    }
  }

  Stream<String> onLinkSpaId() {
    final appLinks = AppLinks();
    return appLinks.uriLinkStream.map((link) {
      final qpId = link.queryParameters['spaId'];
      if (qpId != null && qpId.isNotEmpty) return qpId;
      final extracted = _extractSpaIdFromPath(link);
      return extracted ?? '';
    }).where((id) => id.isNotEmpty);
  }

  String? _extractSpaIdFromPath(Uri link) {
    final segs = link.pathSegments;
    if (segs.length >= 2 && segs[0].toLowerCase() == 'spa') {
      return segs[1];
    }
    return null;
  }
}
