import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Writes bytes to a temp file on non-web platforms. Returns the file path.
Future<String?> downloadPdf(Uint8List bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
