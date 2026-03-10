import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadPdf(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = url;
  anchor.download = filename;
  // Some browsers require the link to be added to DOM
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
