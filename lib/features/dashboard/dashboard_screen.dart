import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../core/utils/seed_data.dart';

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
            appBar: AgroAppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.storage_rounded, color: AppColors.primary),
                  onPressed: () async {
                    await SeedDataGenerator.seedDemoData(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo data seeded successfully!')),
                      );
                    }
                  },
                  tooltip: 'Seed Demo Data',
                ),
              ],
            ),
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
          appBar: AgroAppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.storage_rounded, color: AppColors.primary),
                onPressed: () async {
                  await SeedDataGenerator.seedDemoData(ref);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo data seeded successfully!')),
                    );
                  }
                },
                tooltip: 'Seed Demo Data',
              ),
            ],
          ),
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
                      '${batch.batchNumber} â€¢ Day ${batch.ageInDays}',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryContainer,
                          AppColors.primaryContainer.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 24),
                      label: Text(
                        'LOG ACTIVITY',
                        style: AppTypography.bodyLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        showLogActivitySheet(context, ref);
                      },
                    ),
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
                if (summary.shedSnapshot != null) ...[
                  _buildShedOperationsCard(context, summary.shedSnapshot!),
                  const SizedBox(height: 12),
                ],
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
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.todaysTasks.length > 3
                          ? 3
                          : summary.todaysTasks.length,
                      itemBuilder: (context, index) {
                        final task = summary.todaysTasks[index];
                        return Column(
                          children: [
                            _buildTaskRow(task, ref),
                            if (index < summary.todaysTasks.length - 1 && index < 2)
                              const Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: AppColors.surfaceContainerHigh,
                              ),
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
                          : AppColors.primaryContainer.withValues(alpha: 0.4),
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

  Widget _buildShedOperationsCard(BuildContext context, dynamic shedSnapshot) {
    final reading = shedSnapshot.latestReading;
    final profile = shedSnapshot.profile;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shed Operations', style: AppTypography.headlineMd),
                    Text(
                      shedSnapshot.shed.name,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.push('/home/settings/sheds/${shedSnapshot.shed.id}/control'),
                child: const Text('Open'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reading == null)
            const Text('No environmental check logged yet.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildOpsPill('Temp', '${reading.temperatureC.toStringAsFixed(1)}Â°C'),
                _buildOpsPill(
                    'Humidity', '${reading.humidityPercent.toStringAsFixed(0)}%'),
                _buildOpsPill(
                    'NH3', '${reading.ammoniaPpm?.toStringAsFixed(1) ?? '--'} ppm'),
                _buildOpsPill(
                    'Feed Bin',
                    '${reading.feedBinLevelPercent?.toStringAsFixed(0) ?? '--'}%'),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            'Target ${profile.targetTempMinC.toStringAsFixed(1)}-${profile.targetTempMaxC.toStringAsFixed(1)}Â°C â€¢ '
            '${shedSnapshot.lowStockItems.length} low-stock item(s) â€¢ '
            '${shedSnapshot.treatmentCount} open treatment(s)',
            style: AppTypography.bodyMd,
          ),
        ],
      ),
    );
  }

  Widget _buildOpsPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
      ),
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
