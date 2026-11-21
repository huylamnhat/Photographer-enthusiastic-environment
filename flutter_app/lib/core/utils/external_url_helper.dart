import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalPaymentUrl(String rawUrl) async {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;

  try {
    return await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    return false;
  }
}

Future<void> copyPaymentUrl(String rawUrl) async {
  try {
    await Clipboard.setData(ClipboardData(text: rawUrl.trim()));
  } catch (_) {}
}
