import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/utils/currency_formatter.dart';
import '../data/models/batch_model.dart';
import '../data/models/expense_model.dart';
import '../features/reports/models/report_models.dart';

abstract class PDFService {
  Future<Uint8List> buildFinancialReportBytes({
    required ReportExportPayload report,
  });

  String buildFinancialReportFilename({
    required String farmName,
    DateTime? generatedAt,
  });
}

class DefaultPDFService implements PDFService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF003B1B);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFFFEA619);
  static const PdfColor inkColor = PdfColor.fromInt(0xFF191C19);
  static const PdfColor mutedColor = PdfColor.fromInt(0xFF657168);
  static const PdfColor surfaceColor = PdfColor.fromInt(0xFFF8FAF4);
  static const PdfColor cardColor = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor successColor = PdfColor.fromInt(0xFF0E7A4F);
  static const PdfColor warningColor = PdfColor.fromInt(0xFFB7791F);
  static const PdfColor dangerColor = PdfColor.fromInt(0xFFC53030);

  static _PdfAssets? _cachedAssets;

  const DefaultPDFService();

  @override
  Future<Uint8List> buildFinancialReportBytes({
    required ReportExportPayload report,
  }) async {
    final assets = await _loadAssets();
    final pdf = pw.Document(
      title: '${report.farmName} Financial Report',
      author: 'AgroPrecision',
      subject: 'Farm financial dossier',
    );

    final theme = pw.ThemeData.withFont(
      base: assets.regular,
      bold: assets.bold,
      icons: pw.Font.helvetica(),
    );

    pdf.addPage(
      pw.Page(
        pageTheme: _buildPageTheme(theme, denseMargins: true),
        build: (_) => _buildCoverPage(report, assets),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _buildPageTheme(theme),
        header: (context) => _buildHeader(report, assets, context),
        footer: _buildFooter,
        build: (_) => [
          _buildExecutiveSummary(report),
          pw.SizedBox(height: 24),
          _buildFarmInsights(report),
          pw.SizedBox(height: 24),
          _buildBatchOverview(report.batchPerformanceRows),
        ],
      ),
    );

    for (final batch in report.batches) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: _buildPageTheme(theme),
          header: (context) => _buildHeader(report, assets, context),
          footer: _buildFooter,
          build: (_) => [
            _buildBatchDetailSection(batch),
          ],
        ),
      );
    }

    if (report.batches.isEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageTheme: _buildPageTheme(theme),
          header: (context) => _buildHeader(report, assets, context),
          footer: _buildFooter,
          build: (_) => [
            _buildSectionTitle(
              'Batch Details',
              subtitle:
                  'Detailed batch pages appear here automatically once batch activity exists.',
            ),
            _buildEmptyPanel(
              'No batch activity is available yet. Start logging expenses, sales, mortality, and growth to unlock the full farm dossier.',
            ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  @override
  String buildFinancialReportFilename({
    required String farmName,
    DateTime? generatedAt,
  }) {
    final timestamp = generatedAt ?? DateTime.now();
    final safeFarmName = farmName
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return '${safeFarmName.isEmpty ? 'AgroPrecision' : safeFarmName}_Report_${DateFormat('yyyyMMdd_HHmm').format(timestamp)}.pdf';
  }

  Future<_PdfAssets> _loadAssets() async {
    if (_cachedAssets != null) {
      return _cachedAssets!;
    }

    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Regular.ttf'),
    );
    final semiBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-SemiBold.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-Bold.ttf'),
    );
    final extraBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Manrope-ExtraBold.ttf'),
    );
    final logoBytes = (await rootBundle.load('assets/images/app logo.png'))
        .buffer
        .asUint8List();

    _cachedAssets = _PdfAssets(
      regular: regular,
      semiBold: semiBold,
      bold: bold,
      extraBold: extraBold,
      logo: pw.MemoryImage(logoBytes),
    );

    return _cachedAssets!;
  }

  pw.PageTheme _buildPageTheme(
    pw.ThemeData theme, {
    bool denseMargins = false,
  }) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: denseMargins
          ? const pw.EdgeInsets.all(0)
          : const pw.EdgeInsets.fromLTRB(30, 28, 30, 32),
    );
  }

  pw.Widget _buildCoverPage(ReportExportPayload report, _PdfAssets assets) {
    return pw.Container(
      color: surfaceColor,
      padding: const pw.EdgeInsets.all(38),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(28),
            decoration: const pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(24)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 88,
                  height: 88,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: cardColor,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Image(assets.logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'AgroPrecision',
                        style: pw.TextStyle(
                          font: assets.extraBold,
                          color: PdfColors.white,
                          fontSize: 24,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Farm Financial Dossier',
                        style: pw.TextStyle(
                          font: assets.semiBold,
                          color: PdfColors.white,
                          fontSize: 15,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'A detailed offline report covering financial performance, batch health, and operational activity.',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 28),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(26),
            decoration: pw.BoxDecoration(
              color: cardColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  report.farmName,
                  style: pw.TextStyle(
                    font: assets.extraBold,
                    color: inkColor,
                    fontSize: 28,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Prepared for ${report.ownerName}',
                  style: pw.TextStyle(
                    font: assets.semiBold,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildCoverInfoChip(
                      assets,
                      label: 'Generated',
                      value: _formatFullDate(report.generatedAt),
                    ),
                    _buildCoverInfoChip(
                      assets,
                      label: 'Location',
                      value: report.location ?? 'Not provided',
                    ),
                    _buildCoverInfoChip(
                      assets,
                      label: 'Phone',
                      value: report.phone ?? 'Not provided',
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(22),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFEAF3ED),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(18)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: _buildCoverStat(
                    assets,
                    label: 'Total Revenue',
                    value:
                        CurrencyFormatter.format(report.summary.totalRevenue),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: _buildCoverStat(
                    assets,
                    label: 'Net Profit',
                    value: CurrencyFormatter.format(report.summary.totalProfit),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: _buildCoverStat(
                    assets,
                    label: 'Batches',
                    value: report.summary.batchCount.toString(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCoverInfoChip(
    _PdfAssets assets, {
    required String label,
    required String value,
  }) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(14),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF6F7F4),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              font: assets.bold,
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: assets.semiBold,
              color: inkColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCoverStat(
    _PdfAssets assets, {
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: const pw.BoxDecoration(
        color: cardColor,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              font: assets.bold,
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: assets.extraBold,
              color: primaryColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeader(
    ReportExportPayload report,
    _PdfAssets assets,
    pw.Context context,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 26,
                height: 26,
                padding: const pw.EdgeInsets.all(3),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFEAF3ED),
                  borderRadius: pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Image(assets.logo, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'AgroPrecision',
                    style: pw.TextStyle(
                      font: assets.bold,
                      color: primaryColor,
                      fontSize: 11,
                    ),
                  ),
                  pw.Text(
                    report.farmName,
                    style: const pw.TextStyle(
                      color: mutedColor,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Text(
            'Financial Dossier',
            style: pw.TextStyle(
              font: assets.semiBold,
              color: mutedColor,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 18),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by AgroPrecision',
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildExecutiveSummary(ReportExportPayload report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Executive Summary',
          subtitle:
              'A concise view of farm-wide financial performance and cost efficiency.',
        ),
        pw.SizedBox(height: 16),
        _buildMetricWrap(
          [
            _MetricCardData(
              label: 'Total Revenue',
              value: CurrencyFormatter.format(report.summary.totalRevenue),
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Total Cost',
              value: CurrencyFormatter.format(report.summary.totalCost),
              accent: warningColor,
            ),
            _MetricCardData(
              label: 'Net Profit',
              value: CurrencyFormatter.format(report.summary.totalProfit),
              accent: _profitColor(report.summary.totalProfit),
            ),
            _MetricCardData(
              label: 'Overall ROI',
              value: '${report.summary.overallROI.toStringAsFixed(1)}%',
              accent: secondaryColor,
            ),
            _MetricCardData(
              label: 'Batch Count',
              value: report.summary.batchCount.toString(),
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Avg Cost Per Bird',
              value: CurrencyFormatter.format(report.summary.avgCostPerBird),
              accent: PdfColors.blueGrey700,
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFarmInsights(ReportExportPayload report) {
    final insights = report.insights;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Farm Insights',
          subtitle:
              'Top batch signals, flock totals, and expense concentration across the farm.',
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _buildHighlightPanel(
                title: 'Top Performing Batch',
                highlight: insights.topBatch,
                emptyMessage: 'No batch performance data yet.',
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildHighlightPanel(
                title: 'Weakest Batch',
                highlight: insights.weakestBatch,
                emptyMessage: 'No underperforming batch to compare yet.',
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        _buildMetricWrap(
          [
            _MetricCardData(
              label: 'Birds Placed',
              value: insights.totalBirdsPlaced.toString(),
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Birds Sold',
              value: insights.totalBirdsSold.toString(),
              accent: successColor,
            ),
            _MetricCardData(
              label: 'Birds Alive',
              value: insights.totalBirdsAlive.toString(),
              accent: secondaryColor,
            ),
            _MetricCardData(
              label: 'Birds Lost',
              value: insights.totalBirdsDead.toString(),
              accent: dangerColor,
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        _buildExpenseMixPanel(insights.expenseMix),
      ],
    );
  }

  pw.Widget _buildHighlightPanel({
    required String title,
    required ReportBatchHighlight? highlight,
    required String emptyMessage,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: highlight == null
          ? _buildEmptyState(emptyMessage)
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BATCH SIGNAL',
                  style: const pw.TextStyle(
                    color: mutedColor,
                    fontSize: 8,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  highlight.batchNumber,
                  style: pw.TextStyle(
                    color: inkColor,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Net profit: ${CurrencyFormatter.format(highlight.netProfit)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'ROI: ${highlight.roi.toStringAsFixed(1)}%  |  Status: ${_titleCase(highlight.status.name)}',
                  style: const pw.TextStyle(
                    color: mutedColor,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
    );
  }

  pw.Widget _buildExpenseMixPanel(Map<ExpenseCategory, double> expenseMix) {
    final sortedEntries = expenseMix.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total =
        expenseMix.values.fold<double>(0, (sum, value) => sum + value);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EXPENSE MIX',
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 10),
          if (sortedEntries.isEmpty)
            _buildEmptyState('No expenses recorded yet.')
          else
            ...sortedEntries.map((entry) {
              final share = total == 0 ? 0 : (entry.value / total) * 100;
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          entry.key.displayName,
                          style: const pw.TextStyle(fontSize: 9.5),
                        ),
                        pw.Text(
                          '${CurrencyFormatter.format(entry.value)}  (${share.toStringAsFixed(0)}%)',
                          style: const pw.TextStyle(
                            color: mutedColor,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Stack(
                      children: [
                        pw.Container(
                          height: 6,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.all(
                              pw.Radius.circular(20),
                            ),
                          ),
                        ),
                        pw.Container(
                          width: share.clamp(0, 100).toDouble() * 2.1,
                          height: 6,
                          decoration: pw.BoxDecoration(
                            color: _categoryColor(entry.key),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  pw.Widget _buildBatchOverview(List<BatchPerformanceRow> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Batch Overview',
          subtitle:
              'A farm-wide comparison of batch revenue, cost, profit, and ROI.',
        ),
        pw.SizedBox(height: 16),
        if (rows.isEmpty)
          _buildEmptyPanel(
            'No batch records are available yet. Once you create and operate a batch, it will appear in this overview.',
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(1.15),
              3: pw.FlexColumnWidth(1.1),
              4: pw.FlexColumnWidth(1.1),
              5: pw.FlexColumnWidth(0.9),
            },
            children: [
              _tableHeaderRow(
                const ['Batch', 'Period', 'Revenue', 'Cost', 'Profit', 'ROI'],
              ),
              ...rows.asMap().entries.map((entry) {
                final row = entry.value;
                return _tableDataRow(
                  [
                    row.batchNumber,
                    _formatDateRange(row.startDate, row.endDate),
                    CurrencyFormatter.format(row.revenue),
                    CurrencyFormatter.format(row.costs),
                    CurrencyFormatter.format(row.netProfit),
                    '${row.roi.toStringAsFixed(1)}%',
                  ],
                  shaded: entry.key.isOdd,
                  emphasisIndex: 4,
                  emphasisColor: _profitColor(row.netProfit),
                );
              }),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildBatchDetailSection(ReportBatchDetail batchDetail) {
    final batch = batchDetail.batch;
    final financials = batchDetail.financials;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: const pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(18)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Batch Detail',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      batch.batchNumber,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 21,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      _formatDateRange(batch.startDate, batch.endDate),
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(batch.status),
            ],
          ),
        ),
        pw.SizedBox(height: 18),
        _buildSectionTitle(
          'Profile',
          subtitle: 'Batch setup, targets, and current operating position.',
        ),
        pw.SizedBox(height: 12),
        _buildMetricWrap(
          [
            _MetricCardData(
              label: 'Breed',
              value: batch.breed ?? 'Not set',
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Target Weight',
              value: batch.targetWeightKg == null
                  ? 'Not set'
                  : '${batch.targetWeightKg!.toStringAsFixed(2)} kg',
              accent: secondaryColor,
            ),
            _MetricCardData(
              label: 'Target Days',
              value: batch.targetDays?.toString() ?? 'Not set',
              accent: warningColor,
            ),
            _MetricCardData(
              label: 'Birds Placed',
              value: financials.initialCount.toString(),
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Birds Alive',
              value: financials.currentAlive.toString(),
              accent: successColor,
            ),
            _MetricCardData(
              label: 'Birds Sold',
              value: financials.totalSold.toString(),
              accent: secondaryColor,
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        _buildSectionTitle(
          'Financial Snapshot',
          subtitle:
              'Revenue, cost structure, and commercial outcome for this batch.',
        ),
        pw.SizedBox(height: 12),
        _buildMetricWrap(
          [
            _MetricCardData(
              label: 'Revenue',
              value: CurrencyFormatter.format(financials.totalRevenue),
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Purchase Cost',
              value: CurrencyFormatter.format(financials.purchaseCost),
              accent: warningColor,
            ),
            _MetricCardData(
              label: 'Operating Expenses',
              value: CurrencyFormatter.format(financials.totalExpenses),
              accent: warningColor,
            ),
            _MetricCardData(
              label: 'Total Cost',
              value: CurrencyFormatter.format(financials.totalCost),
              accent: PdfColors.blueGrey700,
            ),
            _MetricCardData(
              label: 'Net Profit',
              value: CurrencyFormatter.format(financials.netProfit),
              accent: _profitColor(financials.netProfit),
            ),
            _MetricCardData(
              label: 'ROI',
              value: '${financials.roi.toStringAsFixed(1)}%',
              accent: secondaryColor,
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        _buildSectionTitle(
          'Operational Metrics',
          subtitle: 'Flock health, production, and breakeven indicators.',
        ),
        pw.SizedBox(height: 12),
        _buildMetricWrap(
          [
            _MetricCardData(
              label: 'Mortality',
              value:
                  '${financials.totalMortality} (${financials.mortalityRate.toStringAsFixed(1)}%)',
              accent: dangerColor,
            ),
            _MetricCardData(
              label: 'Survival Rate',
              value: '${financials.survivalRate.toStringAsFixed(1)}%',
              accent: successColor,
            ),
            _MetricCardData(
              label: 'Latest Weight',
              value: financials.latestWeightKg == null
                  ? 'No record'
                  : '${financials.latestWeightKg!.toStringAsFixed(2)} kg',
              accent: primaryColor,
            ),
            _MetricCardData(
              label: 'Cost Per Bird',
              value: CurrencyFormatter.format(financials.costPerBird),
              accent: warningColor,
            ),
            _MetricCardData(
              label: 'Revenue Per Bird',
              value: CurrencyFormatter.format(financials.revenuePerBird),
              accent: secondaryColor,
            ),
            _MetricCardData(
              label: 'Break-even Price / kg',
              value: financials.breakEvenPricePerKg <= 0
                  ? 'N/A'
                  : '${CurrencyFormatter.format(financials.breakEvenPricePerKg)}/kg',
              accent: PdfColors.blueGrey700,
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        _buildSectionTitle(
          'Expense Categories',
          subtitle: 'Where operating spend is concentrated inside this batch.',
        ),
        pw.SizedBox(height: 12),
        _buildCategoryTable(batchDetail.financials.categoryBreakdown),
        pw.SizedBox(height: 20),
        _buildSectionTitle(
          'Recent Activity',
          subtitle:
              'The latest 10 records captured for each operational stream.',
        ),
        pw.SizedBox(height: 12),
        _buildLogTable(
          title: 'Expenses',
          headers: const ['Date', 'Category', 'Description', 'Amount'],
          rows: batchDetail.recentExpenses
              .map(
                (expense) => [
                  _formatShortDate(expense.date),
                  expense.category.displayName,
                  _truncate(expense.description, 26),
                  CurrencyFormatter.format(expense.amount),
                ],
              )
              .toList(),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.0),
            1: pw.FlexColumnWidth(1.0),
            2: pw.FlexColumnWidth(1.6),
            3: pw.FlexColumnWidth(0.9),
          },
          emptyMessage: 'No expenses logged yet.',
        ),
        pw.SizedBox(height: 12),
        _buildLogTable(
          title: 'Sales',
          headers: const ['Date', 'Birds', 'Weight', 'Price/kg', 'Revenue'],
          rows: batchDetail.recentSales
              .map(
                (sale) => [
                  _formatShortDate(sale.saleDate),
                  sale.birdsSold.toString(),
                  '${sale.averageWeightKg.toStringAsFixed(2)} kg',
                  CurrencyFormatter.format(sale.pricePerKg),
                  CurrencyFormatter.format(sale.totalRevenue),
                ],
              )
              .toList(),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.0),
            1: pw.FlexColumnWidth(0.8),
            2: pw.FlexColumnWidth(1.0),
            3: pw.FlexColumnWidth(0.9),
            4: pw.FlexColumnWidth(1.0),
          },
          emptyMessage: 'No sales logged yet.',
        ),
        pw.SizedBox(height: 12),
        _buildLogTable(
          title: 'Mortality',
          headers: const ['Date', 'Count', 'Cause', 'Notes'],
          rows: batchDetail.recentMortality
              .map(
                (mortality) => [
                  _formatShortDate(mortality.date),
                  mortality.count.toString(),
                  _truncate(mortality.cause ?? 'Not provided', 18),
                  _truncate(mortality.notes ?? '-', 26),
                ],
              )
              .toList(),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.0),
            1: pw.FlexColumnWidth(0.7),
            2: pw.FlexColumnWidth(1.0),
            3: pw.FlexColumnWidth(1.5),
          },
          emptyMessage: 'No mortality logged yet.',
        ),
        pw.SizedBox(height: 12),
        _buildLogTable(
          title: 'Growth',
          headers: const ['Date', 'Day', 'Weight', 'Sample', 'FCR'],
          rows: batchDetail.recentGrowth
              .map(
                (growth) => [
                  _formatShortDate(growth.date),
                  growth.batchDay.toString(),
                  '${growth.averageWeightKg.toStringAsFixed(2)} kg',
                  growth.sampleSize.toString(),
                  growth.feedConversionRatio <= 0
                      ? 'N/A'
                      : growth.feedConversionRatio.toStringAsFixed(2),
                ],
              )
              .toList(),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.0),
            1: pw.FlexColumnWidth(0.7),
            2: pw.FlexColumnWidth(1.0),
            3: pw.FlexColumnWidth(0.8),
            4: pw.FlexColumnWidth(0.7),
          },
          emptyMessage: 'No growth logs yet.',
        ),
      ],
    );
  }

  pw.Widget _buildCategoryTable(Map<ExpenseCategory, double> breakdown) {
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = breakdown.values.fold<double>(0, (sum, value) => sum + value);

    if (sortedEntries.isEmpty) {
      return _buildEmptyPanel(
          'No expense categories were captured for this batch.');
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.6),
        1: pw.FlexColumnWidth(1.0),
        2: pw.FlexColumnWidth(0.8),
      },
      children: [
        _tableHeaderRow(const ['Category', 'Amount', 'Share']),
        ...sortedEntries.asMap().entries.map((entry) {
          final category = entry.value;
          final share = total == 0 ? 0 : (category.value / total) * 100;
          return _tableDataRow(
            [
              category.key.displayName,
              CurrencyFormatter.format(category.value),
              '${share.toStringAsFixed(0)}%',
            ],
            shaded: entry.key.isOdd,
          );
        }),
      ],
    );
  }

  pw.Widget _buildLogTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required String emptyMessage,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 10),
          if (rows.isEmpty)
            _buildEmptyState(emptyMessage)
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: columnWidths,
              children: [
                _tableHeaderRow(headers),
                ...rows.asMap().entries.map((entry) {
                  return _tableDataRow(entry.value, shaded: entry.key.isOdd);
                }),
              ],
            ),
        ],
      ),
    );
  }

  pw.TableRow _tableHeaderRow(List<String> values) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: primaryColor),
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.TableRow _tableDataRow(
    List<String> values, {
    bool shaded = false,
    int? emphasisIndex,
    PdfColor? emphasisColor,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: shaded ? const PdfColor.fromInt(0xFFF6F7F4) : PdfColors.white,
      ),
      children: values.asMap().entries.map((entry) {
        final isEmphasis = entry.key == emphasisIndex;
        return pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            entry.value,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: isEmphasis ? (emphasisColor ?? inkColor) : inkColor,
              fontWeight:
                  isEmphasis ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildStatusBadge(BatchStatus status) {
    final (background, textColor) = switch (status) {
      BatchStatus.active => (secondaryColor, PdfColors.white),
      BatchStatus.completed => (successColor, PdfColors.white),
      BatchStatus.cancelled => (dangerColor, PdfColors.white),
    };

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
      ),
      child: pw.Text(
        _titleCase(status.name),
        style: pw.TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, {String? subtitle}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 6),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 9,
            ),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildMetricWrap(List<_MetricCardData> cards) {
    return pw.Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map(_buildMetricCard).toList(),
    );
  }

  pw.Widget _buildMetricCard(_MetricCardData data) {
    return pw.Container(
      width: 156,
      padding: const pw.EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            data.label.toUpperCase(),
            style: const pw.TextStyle(
              color: mutedColor,
              fontSize: 8,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            data.value,
            style: pw.TextStyle(
              color: data.accent,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmptyPanel(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: _buildEmptyState(message),
    );
  }

  pw.Widget _buildEmptyState(String message) {
    return pw.Text(
      message,
      style: const pw.TextStyle(
        color: mutedColor,
        fontSize: 9.5,
      ),
    );
  }

  pw.BoxDecoration _cardDecoration() {
    return pw.BoxDecoration(
      color: cardColor,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
      border: pw.Border.all(color: PdfColors.grey300),
    );
  }

  PdfColor _profitColor(double value) {
    if (value > 0) {
      return successColor;
    }
    if (value < 0) {
      return dangerColor;
    }
    return primaryColor;
  }

  PdfColor _categoryColor(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.feed => secondaryColor,
      ExpenseCategory.medication => dangerColor,
      ExpenseCategory.labor => PdfColors.blueGrey700,
      ExpenseCategory.utilities => warningColor,
      ExpenseCategory.other => primaryColor,
    };
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _formatShortDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final startLabel = DateFormat('MMM dd, yyyy').format(start);
    final endLabel = DateFormat('MMM dd, yyyy').format(end ?? DateTime.now());
    return '$startLabel - $endLabel';
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) {
      return value;
    }
    return '${value.substring(0, maxChars - 3)}...';
  }
}

class _PdfAssets {
  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;
  final pw.Font extraBold;
  final pw.MemoryImage logo;

  const _PdfAssets({
    required this.regular,
    required this.semiBold,
    required this.bold,
    required this.extraBold,
    required this.logo,
  });
}

class _MetricCardData {
  final String label;
  final String value;
  final PdfColor accent;

  const _MetricCardData({
    required this.label,
    required this.value,
    required this.accent,
  });
}
