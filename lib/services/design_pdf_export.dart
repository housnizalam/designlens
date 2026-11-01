import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds one printable PDF with a static preview and both Design DNA reports.
/// The Arabic TTF must be bundled as an asset to keep exporting fully offline.
class DesignPdfExport {
  static const PdfColor _purple = PdfColor(0.4353, 0.3451, 0.8078);
  static const PdfColor _navy = PdfColor(0.1490, 0.2118, 0.3608);
  static const PdfColor _lightLine = PdfColor(0.8627, 0.8471, 0.9569);

  static pw.Widget _pageHeader(pw.ImageProvider logo) => pw.Directionality(
    textDirection: pw.TextDirection.ltr,
    child: pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _lightLine, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, width: 94, height: 32, fit: pw.BoxFit.contain),
          pw.Text(
            'DESIGN DNA  /  DESIGNLENS',
            style: const pw.TextStyle(
              fontSize: 8,
              color: _navy,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );

  static pw.Widget _pageFooter(pw.Context context) => pw.Directionality(
    textDirection: pw.TextDirection.ltr,
    child: pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _lightLine, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'DesignLens | Design DNA',
            style: const pw.TextStyle(fontSize: 8, color: _navy),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _purple),
          ),
        ],
      ),
    ),
  );

  static Future<void> export({
    required Uint8List desktopPreviewPng,
    required Uint8List mobilePreviewPng,
    required String arabicReport,
    required String englishReport,
  }) async {
    final arabicData = await rootBundle.load(
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(arabicData);
    final document = pw.Document();
    final desktopScreenshot = pw.MemoryImage(desktopPreviewPng);
    final mobileScreenshot = pw.MemoryImage(mobilePreviewPng);
    final logoData = await rootBundle.load(
      'assets/images/branding/designlens_logo.png',
    );
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    // Give the landscape computer reference and the portrait phone reference
    // separate pages so both retain their intended aspect ratio.
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 55, 38, 43),
        header: (_) => _pageHeader(logo),
        footer: (context) => _pageFooter(context),
        build: (_) => [
          pw.Text(
            'Design DNA - Desktop Visual Reference',
            style: pw.TextStyle(
              fontSize: 21,
              fontWeight: pw.FontWeight.bold,
              color: _purple,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Wide desktop layout preview (16:10).',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 22),
          pw.Center(
            child: pw.Image(
              desktopScreenshot,
              fit: pw.BoxFit.contain,
              width: 510,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'A static design reference. Motion and interaction preferences are documented in the reports.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 55, 38, 43),
        header: (_) => _pageHeader(logo),
        footer: (context) => _pageFooter(context),
        build: (_) => [
          pw.Text(
            'Design DNA - Mobile Visual Reference',
            style: pw.TextStyle(
              fontSize: 21,
              fontWeight: pw.FontWeight.bold,
              color: _purple,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Portrait mobile layout preview.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Image(
              mobileScreenshot,
              fit: pw.BoxFit.contain,
              height: 590,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'A static design reference. Motion and interaction preferences are documented in the reports.',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 55, 38, 43),
        header: (_) => _pageHeader(logo),
        footer: (context) => _pageFooter(context),
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
        textDirection: pw.TextDirection.rtl,
        build: (_) =>
            _reportWidgets(arabicReport, arabic: true, font: arabicFont),
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 55, 38, 43),
        header: (_) => _pageHeader(logo),
        footer: (context) => _pageFooter(context),
        build: (_) => _reportWidgets(englishReport, arabic: false),
      ),
    );

    final bytes = await document.save();
    await Printing.layoutPdf(
      name: 'Design_DNA_Complete.pdf',
      onLayout: (_) async => bytes,
    );
  }

  static List<pw.Widget> _reportWidgets(
    String markdown, {
    required bool arabic,
    pw.Font? font,
  }) {
    final widgets = <pw.Widget>[];
    for (final raw in markdown.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) {
        widgets.add(pw.SizedBox(height: 5));
        continue;
      }
      final headingLevel = line.startsWith('### ')
          ? 3
          : line.startsWith('## ')
          ? 2
          : line.startsWith('# ')
          ? 1
          : 0;
      final isNote = line.startsWith('> ');
      final isBullet = line.startsWith('- ');
      final text = headingLevel > 0
          ? line.substring(headingLevel + 1)
          : isNote || isBullet
          ? line.substring(2)
          : line;
      final size = headingLevel == 1
          ? 19.0
          : headingLevel == 2
          ? 14.5
          : headingLevel == 3
          ? 12.0
          : 10.0;
      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(
            top: headingLevel > 0 ? 12 : 1.8,
            bottom: headingLevel > 0 ? 5 : 1.8,
            left: isBullet ? 12 : 0,
            right: isBullet ? 12 : 0,
          ),
          child: pw.Directionality(
            textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (isBullet) ...[
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Container(
                      width: 4,
                      height: 4,
                      decoration: const pw.BoxDecoration(
                        color: _purple,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 7),
                ],
                pw.Expanded(
                  child: pw.Text(
                    _pdfSafeText(_plainMarkdown(text), arabic: arabic),
                    textDirection: arabic
                        ? pw.TextDirection.rtl
                        : pw.TextDirection.ltr,
                    textAlign: arabic ? pw.TextAlign.right : pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: size,
                      fontWeight: headingLevel > 0
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                      color: headingLevel > 0 ? _purple : PdfColors.black,
                      lineSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  static String _plainMarkdown(String value) =>
      value.replaceAll('`', '').replaceAll('**', '');

  // PDF's built-in Latin font does not cover Unicode punctuation, arrows,
  // or decorative symbols. Normalize only unsupported presentation symbols;
  // retain Arabic letters, HEX values, numbers and the actual report content.
  static String _pdfSafeText(String value, {required bool arabic}) {
    return value
        .replaceAll('→', arabic ? ' إلى ' : ' to ')
        .replaceAll('←', arabic ? ' من ' : ' from ')
        .replaceAll('—', ' - ')
        .replaceAll('–', '-')
        .replaceAll('‑', '-')
        .replaceAll('−', '-')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('…', '...')
        .replaceAll('×', 'x')
        .replaceAll('•', '-');
  }
}
