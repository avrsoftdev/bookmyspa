import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ShareService {
  final String scheme;
  final String webBase;

  ShareService({
    this.scheme = 'bookmyspa',
    this.webBase = 'https://bookmyspa.app',
  });

  Future<void> shareSpa({
    required String spaId,
    required String spaName,
    BuildContext? context,
  }) async {
    try {
      final appUrl = Uri.parse('$scheme://spa').replace(queryParameters: {
        'spaId': spaId,
        'name': spaName,
      }).toString();
      final webUrl = Uri.parse('$webBase/spa')
          .replace(queryParameters: {'spaId': spaId}).toString();
      final text = '$spaName on BookMySpa\nOpen in app: $appUrl\nWeb: $webUrl';
      await Share.share(text, subject: spaName);
    } catch (e) {
      final fallbackText =
          '$spaName on BookMySpa\nSpa ID: $spaId\nWeb: $webBase/spa?spaId=$spaId';
      await Share.share(fallbackText, subject: spaName);
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sharing with fallback due to an error')),
        );
      }
    }
  }
}
