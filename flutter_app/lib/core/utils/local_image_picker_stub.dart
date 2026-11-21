import 'package:flutter/services.dart';

class PickedLocalImage {
  final String name;
  final String dataUrl;
  final int sizeBytes;

  PickedLocalImage({
    required this.name,
    required this.dataUrl,
    required this.sizeBytes,
  });
}

Future<List<PickedLocalImage>> pickLocalImagesFromComputer({
  bool multiple = true,
  bool preserveOriginal = false,
}) async {
  return [];
}

String sanitizeGoogleDriveUrl(String raw) {
  final trimmed = raw.trim();
  final match = RegExp(r'https://drive\.google\.com/[^\s\]\)\"''<>]+').firstMatch(trimmed);
  if (match != null) {
    return match.group(0)!.replaceAll(RegExp(r'[.,;:\]\)]+$'), '');
  }
  return trimmed.replaceAll(RegExp(r'[\]\)\s]+$'), '');
}

Future<String> copyTextSafe(String rawText) async {
  final clean = sanitizeGoogleDriveUrl(rawText);
  try {
    await Clipboard.setData(ClipboardData(text: clean));
  } catch (_) {}
  return clean;
}

void openUrlInNewTab(String rawUrl) {}


