import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/mortality_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/repositories/growth_repository.dart';
import '../../../data/repositories/mortality_repository.dart';
import '../../../services/calculation_engine.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/expense_bar_row.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/batch_providers.dart';
import '../../../shared/widgets/animations.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final batchAsync =
        ref.watch(batchRepositoryProvider).getById(widget.batchId);

    return FutureBuilder<BatchModel?>(
      future: batchAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final batch = snapshot.data;
        if (batch == null) {
          return const Scaffold(body: Center(child: Text('Batch not found')));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(batch),
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(batch),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BatchModel batch) {
    final isActive = batch.status == BatchStatus.active;
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          Text(batch.batchNumber, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.outline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isActive ? 'ACTIVE TRACKING' : 'COMPLETED BATCH',
                style: AppTypography.labelBold.copyWith(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildTabItem(0, 'OVERVIEW'),
            _buildTabItem(1, 'EXPENSES'),
            _buildTabItem(2, 'MORTALITY'),
            _buildTabItem(3, 'SALES'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelBold.copyWith(
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BatchModel batch) {
    switch (_selectedTabIndex) {
      case 0:
        return _OverviewTab(batch: batch);
      case 1:
        return _ExpensesTab(batch: batch);
      case 2:
        return _MortalityTab(batch: batch);
      case 3:
        return _SalesTab(batch: batch);
      default:
        return const SizedBox();
    }
  }
}

class _OverviewTab extends ConsumerWidget {
  final BatchModel batch;
  const _OverviewTab({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financialsAsync = ref.watch(batchFinancialsProvider(batch.id));
    final alertsAsync = ref.watch(batchAlertsProvider(batch.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(batchFinancialsProvider(batch.id));
        ref.invalidate(batchAlertsProvider(batch.id));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInsightCard(ref, financialsAsync, alertsAsync),
            const SizedBox(height: 20),
            _buildGrowthChartCard(ref),
            const SizedBox(height: 20),
            _buildMortalityTrendCard(ref, financialsAsync),
            const SizedBox(height: 20),
            _buildExpenseBreakdownCard(ref, financialsAsync),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
      WidgetRef ref,
      AsyncValue<BatchFinancials> financialsAsync,
      AsyncValue<List<ActionAlert>> alertsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            alertsAsync.when(
              loading: () => LoadingSkeleton.skeletonCard(),
              error: (_, __) => const SizedBox.shrink(),
              data: (alerts) {
                final financials = financialsAsync.value;
                String title = "PERFORMANCE ON TRACK";
                String message = "Batch progressing normally.";
                AlertType type = AlertType.info;

                if (financials != null) {
                  if (financials.performanceScore >= 90) {
                    title = "EXCELLENT PERFORMANCE";
                    message = "Growth and mortality are optimized.";
                  } else if (financials.mortalityRate > 3) {
                    title = "MORTALITY ALERT";
                    message = "Mortality exceeds target. Check conditions.";
                    type = AlertType.danger;
                  }
                }

                if (alerts.isNotEmpty) {
                  title = alerts.first.title.toUpperCase();
                  message = alerts.first.message;
                  type = alerts.first.type;
                }

                final color = _getAlertColor(type);

                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          type == AlertType.danger
                              ? Icons.warning_amber_rounded
                              : Icons.auto_awesome_rounded,
                          color: color,
                          size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.labelBold.copyWith(
                                color: type == AlertType.info
                                    ? AppColors.primary
                                    : color,
                                letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: AppTypography.bodyMd
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.danger:
        return AppColors.error;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.success:
        return AppColors.primary;
      default:
        return Colors.amber;
    }
  }

  Widget _buildGrowthChartCard(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("GROWTH PERFORMANCE", style: AppTypography.labelBold.copyWith(letterSpacing: 1.0)),
                Text("WEIGHT (KG)",
                    style: AppTypography.labelBold
                        .copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: RepaintBoundary(
                child: _GrowthLineChart(batchId: batch.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMortalityTrendCard(
      WidgetRef ref, AsyncValue<BatchFinancials> financialsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MORTALITY TREND", style: AppTypography.labelBold.copyWith(letterSpacing: 1.0)),
            const SizedBox(height: 16),
            financialsAsync.when(
              loading: () => LoadingSkeleton.skeletonCard(),
              error: (_, __) => const Text('Error loading mortality'),
              data: (f) => Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CountUpText(
                    value: f.mortalityRate,
                    suffix: '%',
                    style: AppTypography.displayStat.copyWith(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ON TARGET",
                        style: AppTypography.labelBold.copyWith(color: AppColors.primary, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 140,
              child: RepaintBoundary(
                child: _MortalityBarChart(batchId: batch.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdownCard(
      WidgetRef ref, AsyncValue<BatchFinancials> financialsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("EXPENSE BREAKDOWN", style: AppTypography.labelBold.copyWith(letterSpacing: 1.0)),
            const SizedBox(height: 24),
            financialsAsync.when(
              loading: () => LoadingSkeleton.skeletonCard(),
              error: (_, __) => const Text('Error loading expenses'),
              data: (f) {
                final breakdown = f.categoryBreakdown;
                if (breakdown.isEmpty) {
                  return const Center(child: Text('No expenses recorded'));
                }

                final sortedEntries = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                final maxAmount =
                    sortedEntries.isNotEmpty ? sortedEntries.first.value : 1.0;

                return Column(
                  children: sortedEntries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ExpenseBarRow(
                              category: e.key.name.toUpperCase(),
                              amount: e.value,
                              maxAmount: maxAmount,
                              barColor: _getCategoryColor(e.key),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

Color _getCategoryColor(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.feed:
      return AppColors.primary;
    case ExpenseCategory.medication:
      return AppColors.secondary;
    case ExpenseCategory.labor:
      return AppColors.tertiary;
    case ExpenseCategory.utilities:
      return AppColors.outline;
    default:
      return Colors.grey;
  }
}

class _GrowthLineChart extends ConsumerWidget {
  final String batchId;
  const _GrowthLineChart({required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<GrowthChartPoint>>(
      future: ref.read(growthRepositoryProvider).getChartData(batchId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final points = snapshot.data!;

        // Use dummy data for demonstration if empty
        final spots = points.isEmpty
            ? [
                const FlSpot(0, 0.05),
                const FlSpot(7, 0.2),
                const FlSpot(14, 0.5),
                const FlSpot(21, 1.1),
                const FlSpot(28, 1.8),
                const FlSpot(35, 2.4),
              ]
            : points.map((p) => FlSpot(p.day.toDouble(), p.weightKg)).toList();

        final maxDay = spots.last.x;
        final maxWeight = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: maxDay,
            minY: 0,
            maxY: maxWeight + 0.5,
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: 0.5,
              getDrawingHorizontalLine: (value) => const FlLine(
                  color: AppColors.surfaceContainerHigh, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                color: AppColors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.0)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    // Only show dot at latest point
                    if (spot.x == maxDay) {
                      return FlDotCirclePainter(
                          radius: 6,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white);
                    }
                    return FlDotCirclePainter(
                        radius: 0, color: Colors.transparent);
                  },
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => AppColors.primary,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                          '${s.y.toStringAsFixed(2)} kg\nDay ${s.x.toInt()}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MortalityBarChart extends ConsumerWidget {
  final String batchId;
  const _MortalityBarChart({required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<WeeklyMortalityData>>(
      future: ref.read(mortalityRepositoryProvider).getWeeklyBreakdown(batchId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final breakdown = snapshot.data!;

        // Calculate average for color coding
        final avg = breakdown.isEmpty
            ? 0.0
            : breakdown.fold<int>(0, (sum, w) => sum + w.count) /
                breakdown.length;

        return BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('W${value.toInt()}',
                          style: AppTypography.labelMd
                              .copyWith(color: AppColors.onSurfaceVariant)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: breakdown.map((w) {
              final isAboveAvg = w.count > avg;
              return BarChartGroupData(
                x: w.week,
                barRods: [
                  BarChartRodData(
                    toY: w.count.toDouble(),
                    color:
                        isAboveAvg ? AppColors.error : AppColors.errorContainer,
                    width: 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ExpensesTab extends ConsumerWidget {
  final BatchModel batch;
  const _ExpensesTab({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync =
        ref.watch(expenseRepositoryProvider).getByBatch(batch.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<ExpenseModel>>(
        future: expensesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return Center(
                child:
                    Text('No expenses recorded', style: AppTypography.bodyMd));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: expenses.length,
            itemBuilder: (context, i) {
              final e = expenses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(e.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.receipt_long_rounded, 
                        color: _getCategoryColor(e.category), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.description ?? 'Expense',
                              style: AppTypography.labelBold.copyWith(fontSize: 14),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(DateFormatter.toDisplayDate(e.date),
                              style: AppTypography.labelMd
                                  .copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(NumberFormat.currency(symbol: '\$').format(e.amount),
                        style: AppTypography.headlineMd.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/home/batches/${batch.id}/add-expense');
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _MortalityTab extends ConsumerWidget {
  final BatchModel batch;
  const _MortalityTab({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync =
        ref.watch(mortalityRepositoryProvider).getByBatch(batch.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<MortalityModel>>(
        future: logsAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return Center(
                child: Text('No mortality logs recorded',
                    style: AppTypography.bodyMd));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.warning_amber_rounded, 
                        color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${log.count} BIRDS",
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.error,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 2),
                          Text(log.cause ?? 'Unknown cause',
                              style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(DateFormatter.toDisplayDate(log.date),
                        style: AppTypography.labelBold
                            .copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/home/batches/${batch.id}/add-mortality');
        },
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _SalesTab extends ConsumerWidget {
  final BatchModel batch;
  const _SalesTab({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(saleRepositoryProvider).getByBatch(batch.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<SaleModel>>(
        future: salesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sales = snapshot.data!;

          return Column(
            children: [
              if (sales.isNotEmpty) _buildSalesSummary(sales),
              Expanded(
                child: sales.isEmpty
                    ? Center(
                        child: Text('No sales recorded yet',
                            style: AppTypography.bodyMd))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: sales.length,
                        itemBuilder: (context, i) {
                          final s = sales[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.surfaceContainerHigh),
                            ),
                            child: Row(
                              children: [
                                Text(DateFormatter.toDisplayDate(s.saleDate),
                                    style: AppTypography.labelMd.copyWith(
                                        color: AppColors.onSurfaceVariant)),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${s.birdsSold} Birds Sold",
                                          style: AppTypography.bodyLg.copyWith(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "\$${s.pricePerKg.toStringAsFixed(2)} per kg",
                                          style: AppTypography.labelMd.copyWith(
                                              color:
                                                  AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Text(
                                    NumberFormat.currency(symbol: '\$')
                                        .format(s.totalRevenue),
                                    style: AppTypography.bodyLg.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/home/batches/${batch.id}/add-sale');
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildSalesSummary(List<SaleModel> sales) {
    final totalBirds = sales.fold<int>(0, (sum, s) => sum + s.birdsSold);
    final totalRevenue =
        sales.fold<double>(0, (sum, s) => sum + s.totalRevenue);
    final avgPrice = sales.isEmpty
        ? 0.0
        : totalRevenue /
            sales.fold<double>(
                0, (sum, s) => sum + (s.birdsSold * s.averageWeightKg));

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Birds Sold", totalBirds.toString()),
          _summaryItem("Total Revenue",
              NumberFormat.compactCurrency(symbol: '\$').format(totalRevenue)),
          _summaryItem("Avg Price/kg", "\$${avgPrice.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
