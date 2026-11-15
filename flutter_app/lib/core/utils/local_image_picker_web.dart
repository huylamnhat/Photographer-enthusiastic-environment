// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

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

Future<String> _resizeTo1080x720Jpeg(String originalDataUrl) async {
  try {
    final img = html.ImageElement();
    final loadCompleter = Completer<bool>();
    img.onLoad.listen((_) {
      if (!loadCompleter.isCompleted) loadCompleter.complete(true);
    });
    img.onError.listen((_) {
      if (!loadCompleter.isCompleted) loadCompleter.complete(false);
    });
    img.src = originalDataUrl;
    final loaded = await loadCompleter.future.timeout(const Duration(seconds: 5), onTimeout: () => false);
    if (!loaded || (img.naturalWidth == 0 && img.width == 0)) {
      return originalDataUrl;
    }

    final srcW = (img.naturalWidth > 0 ? img.naturalWidth : (img.width ?? 1080)).toDouble();
    final srcH = (img.naturalHeight > 0 ? img.naturalHeight : (img.height ?? 720)).toDouble();

    final canvas = html.CanvasElement(width: 1080, height: 720);
    final ctx = canvas.context2D;
    ctx.fillStyle = '#000000';
    ctx.fillRect(0, 0, 1080, 720);

    final targetRatio = 1080.0 / 720.0;
    final srcRatio = srcW / srcH;

    double sx = 0, sy = 0, sw = srcW, sh = srcH;
    if (srcRatio > targetRatio) {
      sw = srcH * targetRatio;
      sx = (srcW - sw) / 2.0;
    } else {
      sh = srcW / targetRatio;
      sy = (srcH - sh) / 2.0;
    }

    ctx.drawImageScaledFromSource(img, sx, sy, sw, sh, 0, 0, 1080, 720);
    return canvas.toDataUrl('image/jpeg', 0.90);
  } catch (_) {
    return originalDataUrl;
  }
}

Future<List<PickedLocalImage>> pickLocalImagesFromComputer({bool multiple = true}) async {
  final completer = Completer<List<PickedLocalImage>>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = multiple;

  input.onChange.listen((_) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete([]);
      return;
    }
    final results = <PickedLocalImage>[];
    for (final file in files) {
      final reader = html.FileReader();
      final fileCompleter = Completer<String?>();
      reader.onLoadEnd.listen((_) {
        fileCompleter.complete(reader.result as String?);
      });
      reader.onError.listen((_) {
        fileCompleter.complete(null);
      });
      reader.readAsDataUrl(file);
      final rawDataUrl = await fileCompleter.future;
      if (rawDataUrl != null && rawDataUrl.isNotEmpty) {
        final resizedDataUrl = await _resizeTo1080x720Jpeg(rawDataUrl);
        results.add(
          PickedLocalImage(
            name: file.name,
            dataUrl: resizedDataUrl,
            sizeBytes: file.size,
          ),
        );
      }
    }
    if (!completer.isCompleted) {
      completer.complete(results);
    }
  });

  input.click();
  return completer.future;
}

String sanitizeGoogleDriveUrl(String raw) {
  final trimmed = raw.trim();
  final folderIdMatch = RegExp(r'/folders/([a-zA-Z0-9_-]{15,})').firstMatch(trimmed);
  if (folderIdMatch != null && folderIdMatch.group(1) != null) {
    return 'https://drive.google.com/drive/folders/${folderIdMatch.group(1)}?usp=sharing';
  }
  final match = RegExp(r'https://drive\.google\.com/[^\s\]\)\"''<>]+').firstMatch(trimmed);
  if (match != null) {
    return match.group(0)!.replaceAll(RegExp(r'[.,;:\]\)]+$'), '');
  }
  return trimmed.replaceAll(RegExp(r'[\]\)\s]+$'), '');
}

Future<String> copyTextSafe(String rawText) async {
  final clean = sanitizeGoogleDriveUrl(rawText);

  // 1. Works on plain HTTP (e.g. http://192.168.1.7:8080 on mobile Chrome/Safari) where navigator.clipboard is blocked
  try {
    final textArea = html.TextAreaElement()
      ..value = clean
      ..readOnly = false
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '2em'
      ..style.height = '2em'
      ..style.padding = '0'
      ..style.border = 'none'
      ..style.outline = 'none'
      ..style.boxShadow = 'none'
      ..style.background = 'transparent'
      ..style.opacity = '0';
    html.document.body?.append(textArea);
    textArea.focus();
    textArea.select();
    textArea.setSelectionRange(0, clean.length);
    html.document.execCommand('copy');
    textArea.remove();
  } catch (_) {}

  // 2. Also try navigator.clipboard if available (HTTPS / localhost)
  try {
    final clipboard = html.window.navigator.clipboard;
    if (clipboard != null) {
      await clipboard.writeText(clean);
    }
  } catch (_) {}

  return clean;
}

void openUrlInNewTab(String rawUrl) {
  final clean = sanitizeGoogleDriveUrl(rawUrl);
  if (clean.isEmpty) return;
  try {
    final anchor = html.AnchorElement(href: clean)
      ..target = '_blank'
      ..rel = 'noopener noreferrer';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  } catch (_) {
    try {
      html.window.open(clean, '_blank');
    } catch (_) {}
  }
}


