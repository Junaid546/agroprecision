import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../features/reports/providers/report_providers.dart';
import '../core/utils/currency_formatter.dart';
import 'calculation_engine.dart';

class PDFService {
  static Future<void> generateFinancialReport({
    required String farmName,
    required String ownerName,
    required FarmSummaryFinancials summary,
    required List<BatchPerformanceRow> batches,
    required List<BatchFinancials> detailedBatches,
  }) async {
    final Uint8List pdfData = await compute(_buildPdfDocument, {
      'farmName': farmName,
      'ownerName': ownerName,
      'summary': summary,
      'batches': batches,
      'detailedBatches': detailedBatches,
    });

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  static Future<Uint8List> _buildPdfDocument(Map<String, dynamic> data) async {
    final farmName = data['farmName'] as String;
    final ownerName = data['ownerName'] as String;
    final summary = data['summary'] as FarmSummaryFinancials;
    final batches = data['batches'] as List<BatchPerformanceRow>;
    final detailedBatches = data['detailedBatches'] as List<BatchFinancials>;

    final pdf = pw.Document();

    // 1. Cover Page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(farmName,
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Financial Performance Report',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 40),
              pw.Text('Owner: $ownerName',
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text(
                  'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    // 2. Financial Summary Page
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Financial Summary'),
            pw.SizedBox(height: 20),
            _buildSummaryRow(
                'Total Profit', CurrencyFormatter.format(summary.totalProfit)),
            _buildSummaryRow(
                'Overall ROI', '${summary.overallROI.toStringAsFixed(1)}%'),
            _buildSummaryRow('Avg. Cost / Chicken',
                CurrencyFormatter.format(summary.avgCostPerBird)),
            pw.SizedBox(height: 40),
            pw.Header(level: 1, text: 'Batch Performance Breakdown'),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _tableCell('Batch ID', isHeader: true),
                    _tableCell('Revenue', isHeader: true),
                    _tableCell('Costs', isHeader: true),
                    _tableCell('Net Profit', isHeader: true),
                  ],
                ),
                ...batches.map((b) => pw.TableRow(
                      children: [
                        _tableCell(b.batchNumber),
                        _tableCell(CurrencyFormatter.format(b.revenue)),
                        _tableCell(CurrencyFormatter.format(b.costs)),
                        _tableCell(CurrencyFormatter.format(b.netProfit)),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );

    // 3. Detailed Batch Reports
    for (final batch in detailedBatches) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Batch Report: ${batch.batchId}'),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Status: ${batch.status.name.toUpperCase()}'),
                  pw.Text('Initial Count: ${batch.initialCount}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Expense Breakdown',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _tableCell('Category', isHeader: true),
                      _tableCell('Amount', isHeader: true),
                    ],
                  ),
                  ...batch.categoryBreakdown.entries.map((e) => pw.TableRow(
                        children: [
                          _tableCell(e.key.name),
                          _tableCell(CurrencyFormatter.format(e.value)),
                        ],
                      )),
                ],
              ),
              pw.SizedBox(height: 20),
              _buildSummaryRow('Mortality Summary',
                  '${batch.totalMortality} birds (${batch.mortalityRate.toStringAsFixed(1)}%)'),
              _buildSummaryRow('Total Sold', '${batch.totalSold} birds'),
              _buildSummaryRow(
                  'Net Profit', CurrencyFormatter.format(batch.netProfit)),
              _buildSummaryRow('Batch ROI', '${batch.roi.toStringAsFixed(1)}%'),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
