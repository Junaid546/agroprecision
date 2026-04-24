import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/analytics_providers.dart';
import '../../../data/models/expense_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(title: 'Advanced Analytics'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm Insights', style: AppTypography.headlineLg),
            Text(
              'Deep dive into your production performance.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // CHART 1: Profit Trend
            _AnalyticsCard(
              title: 'Profit by Batch',
              subtitle: 'Chronological net profit trend',
              child: _ProfitTrendChart(),
            ),

            const SizedBox(height: 16),

            // CHART 2: Expense Distribution
            _AnalyticsCard(
              title: 'Cost Breakdown',
              subtitle: 'Across all batches',
              child: _ExpenseDistributionChart(),
            ),

            const SizedBox(height: 16),

            // CHART 3: Mortality Rate Heatmap
            _AnalyticsCard(
              title: 'Mortality Rate Over Time',
              subtitle: 'Weekly average percentage',
              child: _MortalityTrendChart(),
            ),

            const SizedBox(height: 16),

            // CHART 4: FCR Trend
            _AnalyticsCard(
              title: 'Feed Conversion Ratio',
              subtitle: 'Efficiency metric (Lower is better)',
              child: _FCRTrendChart(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineMd),
          Text(subtitle, style: AppTypography.labelMd),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ProfitTrendChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(profitTrendProvider);

    return trendAsync.when(
      data: (data) {
        if (data.isEmpty)
          return const EmptyState(
              title: 'No Profit Data',
              message: 'Finish a batch to see trends.');

        return RepaintBoundary(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.outlineVariant.withOpacity(0.3),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length)
                        return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          data[index].batchNumber.split('-').last,
                          style: AppTypography.labelMd.copyWith(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        NumberFormat.compactCurrency(symbol: '\$')
                            .format(value),
                        style: AppTypography.labelMd.copyWith(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.netProfit))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: AppColors.outline,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (line) => 'Break-even',
                      style: AppTypography.labelMd.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => AppColors.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final batch = data[spot.x.toInt()];
                      return LineTooltipItem(
                        '${batch.batchNumber}\n',
                        AppTypography.bodyMd
                            .copyWith(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: NumberFormat.currency(symbol: '\$')
                                .format(spot.y),
                            style: AppTypography.labelBold.copyWith(
                                color: spot.y >= 0
                                    ? AppColors.successText
                                    : AppColors.error),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => LoadingSkeleton.skeletonAnalytics(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ExpenseDistributionChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributionAsync = ref.watch(expenseDistributionProvider);

    return distributionAsync.when(
      data: (data) {
        if (data.isEmpty)
          return const EmptyState(
              title: 'No Expenses',
              message: 'Log expenses to see distribution.');

        final total = data.values.fold(0.0, (a, b) => a + b);

        return Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: data.entries.map((e) {
                          return PieChartSectionData(
                            color: e.key.color,
                            value: e.value,
                            title: '',
                            radius: 18,
                            showTitle: false,
                          );
                        }).toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total', style: AppTypography.labelMd),
                        Text(
                          NumberFormat.compactCurrency(symbol: '\$')
                              .format(total),
                          style: AppTypography.headlineMd
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: data.entries.map((e) {
                final percent = (e.value / total) * 100;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${e.key.name.toUpperCase()} ${percent.toStringAsFixed(0)}%',
                      style: AppTypography.labelMd.copyWith(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => LoadingSkeleton.skeletonAnalytics(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) => category.color;
}

class _MortalityTrendChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(mortalityTrendProvider);

    return trendAsync.when(
      data: (data) {
        if (data.isEmpty)
          return const EmptyState(
              title: 'No Mortality Data',
              message: 'Safe production starts here.');

        return RepaintBoundary(
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('W${value.toInt()}',
                            style:
                                AppTypography.labelMd.copyWith(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.map((p) {
                return BarChartGroupData(
                  x: p.week,
                  barRods: [
                    BarChartRodData(
                      toY: p.mortalityRate,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.successText,
                          p.mortalityRate > 5.0
                              ? AppColors.error
                              : (p.mortalityRate > 1.0
                                  ? AppColors.primary
                                  : AppColors.successText),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 16,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 1.0,
                    color: AppColors.outline,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Target < 1%',
                      style: AppTypography.labelMd.copyWith(fontSize: 9),
                    ),
                  ),
                ],
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppColors.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      'Week ${group.x}\n',
                      AppTypography.bodyMd
                          .copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toStringAsFixed(2)}%',
                          style: AppTypography.labelBold.copyWith(
                              color: rod.toY > 1.0
                                  ? AppColors.error
                                  : AppColors.successText),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => LoadingSkeleton.skeletonAnalytics(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _FCRTrendChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fcrAsync = ref.watch(fcrTrendProvider);

    return fcrAsync.when(
      data: (data) {
        if (data.isEmpty)
          return const EmptyState(
              title: 'No Growth Logs', message: 'Record weights to track FCR.');

        return RepaintBoundary(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 7 != 0) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Day ${value.toInt()}',
                            style:
                                AppTypography.labelMd.copyWith(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .map((l) =>
                          FlSpot(l.batchDay.toDouble(), l.feedConversionRatio))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 1.8,
                    color: Colors.orange,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => 'Target 1.8',
                      style: AppTypography.labelMd.copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => AppColors.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Day ${spot.x.toInt()}\n',
                        AppTypography.bodyMd
                            .copyWith(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'FCR: ${spot.y.toStringAsFixed(2)}',
                            style: AppTypography.labelBold.copyWith(
                                color: spot.y > 1.8
                                    ? AppColors.error
                                    : AppColors.primary),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
      loading: () => LoadingSkeleton.skeletonAnalytics(),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
