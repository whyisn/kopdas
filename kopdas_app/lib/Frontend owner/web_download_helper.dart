// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void downloadWebFile(String content, String fileName) {
  if (kIsWeb) {
    // Add UTF-8 BOM so Microsoft Excel opens Indonesian accents / currency without encoding issues
    final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(content)];
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
