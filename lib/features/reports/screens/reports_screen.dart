import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/animations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/metric_card.dart';
import '../models/report_models.dart';
import '../providers/report_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(farmSummaryProvider);
    final performanceAsync = ref.watch(batchPerformanceListProvider);

    return Scaffold(
      appBar: const AgroAppBar(showOfflineIndicator: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Reports', style: AppTypography.headlineLg),
            Text(
              'Professional summaries and ROI tracking.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _generatePDFReport(context);
                      },
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 20),
                label: Text(
                  _isGeneratingPdf ? 'Preparing PDF...' : 'Generate PDF Report',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/home/reports/analytics');
                },
                icon: const Icon(Icons.analytics_outlined, size: 20),
                label: const Text('View Detailed Analytics'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  MetricCard(
                    label: 'TOTAL FARM PROFIT',
                    value: CountUpText(
                      value: summary.totalProfit,
                      prefix: '\$',
                      style: AppTypography.displayStat,
                    ),
                    trend: '+12% vs last quarter',
                    trendDirection: TrendDirection.up,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MetricCard(
                    label: 'ROI',
                    value: CountUpText(
                      value: summary.overallROI,
                      suffix: '%',
                      style: AppTypography.displayStat,
                    ),
                    trend: '+2.1% YoY',
                    trendDirection: TrendDirection.up,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.successBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MetricCard(
                    label: 'AVG. COST / CHICKEN',
                    value:
                        CurrencyFormatter.formatPerBird(summary.avgCostPerBird),
                    trend: '-0.05 vs target',
                    trendDirection: TrendDirection.down,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.activeChipBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => Column(
                children: [
                  LoadingSkeleton.skeletonCard(),
                  const SizedBox(height: 12),
                  LoadingSkeleton.skeletonCard(),
                  const SizedBox(height: 12),
                  LoadingSkeleton.skeletonCard(),
                ],
              ),
              error: (e, __) =>
                  Center(child: Text('Error loading summary: $e')),
            ),
            const SizedBox(height: 24),
            _buildBatchPerformanceTable(context, performanceAsync),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchPerformanceTable(
    BuildContext context,
    AsyncValue<List<BatchPerformanceRow>> performanceAsync,
  ) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Batch Performance Breakdown',
                    style: AppTypography.headlineMd,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.filter_list),
              ],
            ),
          ),
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('BATCH ID', style: AppTypography.labelBold),
                ),
                Expanded(
                  flex: 2,
                  child: Text('DATE RANGE', style: AppTypography.labelBold),
                ),
                Expanded(
                  flex: 2,
                  child: Text('REVENUE', style: AppTypography.labelBold),
                ),
                Expanded(
                  flex: 2,
                  child: Text('COSTS', style: AppTypography.labelBold),
                ),
                Expanded(
                  flex: 2,
                  child: Text('NET PRO...', style: AppTypography.labelBold),
                ),
              ],
            ),
          ),
          performanceAsync.when(
            data: (rows) {
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: EmptyState(
                    title: 'No Data Yet',
                    message:
                        'Once you start a batch, financial reports will appear here.',
                    actionLabel: 'Start First Batch',
                    onAction: () => context.push('/home/batches/new'),
                    icon: Icons.analytics_outlined,
                  ),
                );
              }
              return Column(
                children: rows.map((row) => _buildTableRow(row)).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, __) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BatchPerformanceRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.batchNumber,
              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormatter.toDateRange(
                row.startDate,
                row.endDate ?? DateTime.now(),
              ),
              style: AppTypography.bodyMd,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(row.revenue),
              style: AppTypography.bodyMd,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(row.costs),
              style: AppTypography.bodyMd,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.format(row.netProfit),
              style: AppTypography.bodyMd.copyWith(
                color: row.netProfit >= 0
                    ? AppColors.successText
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDFReport(BuildContext context) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final summary = await ref.read(farmSummaryProvider.future);
      final performanceRows =
          await ref.read(batchPerformanceListProvider.future);
      final farm = ref.read(currentFarmProvider);
      final report = await ref.read(reportExportAssemblerProvider).buildReport(
            farm: farm,
            summary: summary,
            performanceRows: performanceRows,
          );
      final pdfService = ref.read(pdfServiceProvider);
      final filename = pdfService.buildFinancialReportFilename(
        farmName: report.farmName,
        generatedAt: report.generatedAt,
      );
      final bytes = await pdfService.buildFinancialReportBytes(report: report);

      if (context.mounted) {
        context.push(
          '/home/reports/preview',
          extra: ReportPreviewArgs(bytes: bytes, filename: filename),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }
}
