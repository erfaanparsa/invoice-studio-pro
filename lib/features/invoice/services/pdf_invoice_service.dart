import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/core/utils/formatters.dart';
import 'package:invoice_studio_pro/core/utils/number_to_words.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_document.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInvoiceService {
  const PdfInvoiceService();

  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF4F46E5);
  static const PdfColor _slateDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor _slateMuted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _surfaceLight = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _borderLight = PdfColor.fromInt(0xFFE2E8F0);

  /// Generates raw PDF bytes for any platform (Web, iOS, Android, Desktop).
  Future<Uint8List> buildPdfBytes(InvoiceDocument invoice) async {
    final pdf = pw.Document(
      title: 'Invoice ${invoice.invoiceNumber}',
      author: invoice.companyName,
      creator: 'Invoice Studio Pro',
    );

    final amountInWords = NumberToWordsConverter.convertUsdToWords(
      invoice.grandTotal,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _buildPageTheme(),
        header: (context) => _buildHeader(invoice),
        footer: (context) => _buildFooter(context, invoice),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildPartiesSection(invoice),
          pw.SizedBox(height: 24),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildTotalsAndSummary(invoice, amountInWords),
          if (invoice.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _buildNotesBox(invoice.notes),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  /// Opens the native/web print & preview dialog.
  Future<void> previewAndPrintPdf(InvoiceDocument invoice) async {
    await Printing.layoutPdf(
      name: '${invoice.invoiceNumber}.pdf',
      onLayout: (_) => buildPdfBytes(invoice),
    );
  }

  /// Shares or downloads the generated PDF file across Web and Mobile.
  Future<void> shareOrDownloadPdf(InvoiceDocument invoice) async {
    final bytes = await buildPdfBytes(invoice);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${invoice.invoiceNumber}.pdf',
    );
  }

  pw.PageTheme _buildPageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.ltr,
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
  }

  pw.Widget _buildHeader(InvoiceDocument invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _borderLight, width: 1.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                invoice.companyName.isEmpty
                    ? 'Enterprise Studio'
                    : invoice.companyName,
                style: const pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _slateDark,
                ),
              ),
              if (invoice.companyEmail.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.companyEmail,
                  style: const pw.TextStyle(fontSize: 10, color: _slateMuted),
                ),
              ],
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _primaryColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'INVOICE',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '#${invoice.invoiceNumber}',
                style: const pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _slateDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPartiesSection(InvoiceDocument invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _surfaceLight,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderLight),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _slateMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.clientName.isEmpty
                      ? 'Valued Client'
                      : invoice.clientName,
                  style: const pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _slateDark,
                  ),
                ),
                if (invoice.clientEmail.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    invoice.clientEmail,
                    style: const pw.TextStyle(fontSize: 10, color: _slateMuted),
                  ),
                ],
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildDateRow(
                  'Issue Date:',
                  AppFormatters.formatDate(invoice.issueDate),
                ),
                pw.SizedBox(height: 4),
                _buildDateRow(
                  'Due Date:',
                  AppFormatters.formatDate(invoice.dueDate),
                ),
                pw.SizedBox(height: 4),
                _buildDateRow('Currency:', 'USD (\$)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDateRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: _slateMuted),
        ),
        pw.SizedBox(width: 6),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _slateDark,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(InvoiceDocument invoice) {
    final headers = ['#', 'Item & Description', 'Qty', 'Unit Price', 'Amount'];

    final data = invoice.items.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      final itemLabel = item.description.trim().isEmpty
          ? item.name
          : '${item.name}\n${item.description}';
      return [
        index.toString(),
        itemLabel,
        item.quantity.toString(),
        AppFormatters.formatCurrency(item.unitPrice),
        AppFormatters.formatCurrency(item.total),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _borderLight, width: 0.8),
        bottom: pw.BorderSide(color: _borderLight, width: 1.2),
      ),
      headerStyle: const pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: _slateDark),
      cellStyle: const pw.TextStyle(color: _slateDark, fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(4.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.8),
        4: const pw.FlexColumnWidth(1.8),
      },
    );
  }

  pw.Widget _buildTotalsAndSummary(
    InvoiceDocument invoice,
    String amountInWords,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _surfaceLight,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _borderLight),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AMOUNT IN WORDS (USD)',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _slateMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  amountInWords,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _slateDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            children: [
              _buildSummaryRow(
                'Total Quantity',
                '${invoice.totalQuantity} units',
              ),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                'Subtotal',
                AppFormatters.formatCurrency(invoice.subtotal),
              ),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                'Tax (${invoice.taxRatePercent.toStringAsFixed(1)}%)',
                AppFormatters.formatCurrency(invoice.taxAmount),
              ),
              pw.Divider(color: _borderLight, height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: _primaryColor,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Due',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    pw.Text(
                      AppFormatters.formatCurrency(invoice.grandTotal),
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: _slateMuted),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: _slateDark,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNotesBox(String notes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PAYMENT TERMS & NOTES',
          style: const pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _slateMuted,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          notes,
          style: const pw.TextStyle(fontSize: 9.5, color: _slateDark),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, InvoiceDocument invoice) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderLight, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by ${invoice.companyName.isEmpty ? "Invoice Studio Pro" : invoice.companyName}',
            style: const pw.TextStyle(fontSize: 9, color: _slateMuted),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: _slateMuted),
          ),
        ],
      ),
    );
  }
}

final pdfInvoiceServiceProvider = Provider<PdfInvoiceService>((ref) {
  return const PdfInvoiceService();
});
