import 'file_exporter_stub.dart'
    if (dart.library.html) 'file_exporter_web.dart' as exporter;

class FileExporter {
  /// تصدير محتوى CSV وتنزيله
  static Future<void> downloadCsv(String content, String fileName) async {
    await exporter.downloadCsvImpl(content, fileName);
  }

  /// فتح تقرير HTML في نافذة جديدة للطباعة أو حفظه كـ PDF
  static Future<void> printHtmlReport(String htmlContent, String title) async {
    await exporter.printHtmlReportImpl(htmlContent, title);
  }
}
