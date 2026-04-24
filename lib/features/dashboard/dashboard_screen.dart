import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/alert_banner.dart';
import '../../../shared/widgets/metric_card.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/dashboard_skeleton.dart';
import 'widgets/log_activity_sheet.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/animations.dart';
import '../../../data/models/task_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void showLogActivitySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogActivitySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return summaryAsync.when(
      loading: () => const Scaffold(
        appBar: AgroAppBar(),
        body: DashboardSkeleton(),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading dashboard: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardSummaryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (summary) {
        final batch = summary.activeBatch;
        if (batch == null) {
          return Scaffold(
            appBar: const AgroAppBar(),
            body: EmptyState(
              title: 'No Active Batch',
              message:
                  'You haven\'t started a batch yet. Start your first batch to see dashboard analytics.',
              actionLabel: 'Start First Batch',
              onAction: () => context.push('/home/batches/new'),
              icon: Icons.analytics_outlined,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: const AgroAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: AppTypography.headlineLg),
                    Text(
                      'Batch #${batch.batchNumber} (Day ${batch.ageInDays})',
                      style: AppTypography.bodyMd,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    label: Text(
                      'Log Activity',
                      style: AppTypography.bodyLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      showLogActivitySheet(context, ref);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ...summary.alerts.take(2).map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AlertBanner(
                        type: alert.type,
                        title: alert.title,
                        message: alert.message,
                      ),
                    )),
                const SizedBox(height: 8),
                _buildProfitCard(
                    summary.financials, summary.last5BatchesProfit),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAliveCard(summary.financials),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMortalityCard(
                          summary.todaysMortality, summary.financials),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExpensesCard(summary.financials),
                const SizedBox(height: 24),
                Text("Today's Tasks", style: AppTypography.headlineMd),
                const SizedBox(height: 12),
                if (summary.todaysTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No tasks scheduled for today')),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.todaysTasks.length > 3
                          ? 3
                          : summary.todaysTasks.length,
                      itemBuilder: (context, index) {
                        final task = summary.todaysTasks[index];
                        return Column(
                          children: [
                            _buildTaskRow(task, ref),
                            if (index < 2 &&
                                index < summary.todaysTasks.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfitCard(dynamic financials, List<double> history) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return MetricCard(
      label: "ESTIMATED PROFIT",
      value: CountUpText(
        value: financials?.netProfit ?? 0.0,
        prefix: '\$',
        style: AppTypography.displayStat,
      ),
      trend: "+12%",
      trendDirection: TrendDirection.up,
      icon: Container(
        height: 72,
        padding: const EdgeInsets.only(top: 16),
        child: RepaintBoundary(
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: history.asMap().entries.map((e) {
                final isCurrent = e.key == history.length - 1;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.primaryContainer.withOpacity(0.4),
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAliveCard(dynamic financials) {
    final numFormat = NumberFormat('#,###');
    final survivalRate = financials?.survivalRate ?? 0;

    return MetricCard(
      label: "Total Chickens Alive",
      value: CountUpText(
        value: (financials?.currentAlive ?? 0).toDouble(),
        decimalDigits: 0,
        style: AppTypography.displayStat,
      ),
      trend: survivalRate > 90 ? "Good" : null,
      trendDirection: survivalRate > 90 ? TrendDirection.neutral : null,
      icon: const Icon(Icons.pets, color: AppColors.onSurfaceVariant, size: 20),
    );
  }

  Widget _buildMortalityCard(int todaysMortality, dynamic financials) {
    final threshold = ((financials?.initialCount ?? 100) * 0.01).ceil();
    final exceeded = todaysMortality > threshold;

    return MetricCard(
      label: "Today's Mortality",
      value: todaysMortality.toString(),
      borderLeftColor: exceeded ? AppColors.error : null,
      icon: Icon(
        exceeded ? Icons.warning_rounded : Icons.warning_amber_rounded,
        color: exceeded ? AppColors.error : AppColors.outline,
        size: 20,
      ),
    );
  }

  Widget _buildExpensesCard(dynamic financials) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return MetricCard(
      label: "Total Expenses",
      value: CountUpText(
        value: financials?.totalCost ?? 0.0,
        prefix: '\$',
        style: AppTypography.displayStat,
      ),
      icon: const Icon(Icons.account_balance_wallet,
          color: AppColors.onSurfaceVariant, size: 20),
    );
  }

  Widget _buildTaskRow(TaskModel task, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: task.status == TaskStatus.done,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                ref.read(dashboardTaskActionProvider).toggleTask(task);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.inlineGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyLg
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                if (task.description != null)
                  Text(
                    task.description!,
                    style: AppTypography.labelMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.scheduledTime ?? '--:--',
              style: AppTypography.labelBold
                  .copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
