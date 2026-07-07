import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

Future<void> downloadCsvImpl(String content, String fileName) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content, encoding: utf8);
    await Share.shareXFiles([XFile(file.path)], text: 'تصدير كشف الأكاديمية');
  } catch (e) {
    print('Error exporting CSV: $e');
  }
}

Future<void> printHtmlReportImpl(String htmlContent, String title) async {
  try {
    await Printing.layoutPdf(
      name: title,
      onLayout: (format) async => await Printing.convertHtml(
        format: format,
        html: htmlContent,
      ),
    );
  } catch (e) {
    print('Error printing HTML: $e');
  }
}
