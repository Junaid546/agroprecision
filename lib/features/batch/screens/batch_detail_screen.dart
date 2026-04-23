import 'package:flutter/material.dart';
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
    final batchAsync = ref.watch(batchRepositoryProvider).getById(widget.batchId);

    return FutureBuilder<BatchModel?>(
      future: batchAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Text(batch.batchNumber, style: AppTypography.headlineMd),
          const SizedBox(width: 12),
          StatusChip(
            label: isActive ? 'Active' : 'Completed',
            status: isActive ? ChipStatus.active : ChipStatus.completed,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.onSurface, size: 20),
              onPressed: () {}, // TODO: Edit batch
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, 'Overview'),
              _buildTabItem(1, 'Expenses'),
              _buildTabItem(2, 'Mortality'),
              _buildTabItem(3, 'Sales'),
            ],
          ),
          const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BatchModel batch) {
    switch (_selectedTabIndex) {
      case 0: return _OverviewTab(batch: batch);
      case 1: return _ExpensesTab(batch: batch);
      case 2: return _MortalityTab(batch: batch);
      case 3: return _SalesTab(batch: batch);
      default: return const SizedBox();
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

  Widget _buildInsightCard(WidgetRef ref, AsyncValue<BatchFinancials> financialsAsync, AsyncValue<List<ActionAlert>> alertsAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            alertsAsync.when(
              loading: () => const LoadingSkeletonCard(),
              error: (_, __) => const SizedBox.shrink(),
              data: (alerts) {
                final financials = financialsAsync.value;
                String title = "Performance on track";
                String message = "Batch progressing normally.";
                AlertType type = AlertType.info;

                if (financials != null) {
                  if (financials.performanceScore >= 90) {
                    title = "Performance on track";
                    message = "Current weight gain and mortality are optimized for this stage.";
                  } else if (financials.mortalityRate > 3) {
                    title = "Mortality elevated";
                    message = "Review ventilation and feeding schedule. Mortality exceeds target.";
                    type = AlertType.danger;
                  }
                }

                // If explicit alerts exist, override
                if (alerts.isNotEmpty) {
                  title = alerts.first.title;
                  message = alerts.first.message;
                  type = alerts.first.type;
                }

                final color = _getAlertColor(type);

                return Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        type == AlertType.danger ? Icons.warning_rounded : Icons.lightbulb_outline,
                        color: color, 
                        size: 20
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: type == AlertType.info ? AppColors.primary : color
                            ),
                          ),
                          Text(
                            message,
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
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
      case AlertType.danger: return AppColors.error;
      case AlertType.warning: return Colors.orange;
      case AlertType.success: return AppColors.primary;
      default: return Colors.amber;
    }
  }

  Widget _buildGrowthChartCard(WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Growth Chart", style: AppTypography.headlineMd),
                Text("Weight (kg) over time", style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _GrowthLineChart(batchId: batch.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMortalityTrendCard(WidgetRef ref, AsyncValue<BatchFinancials> financialsAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mortality Trend", style: AppTypography.headlineMd),
                const Icon(Icons.trending_down, color: AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            financialsAsync.when(
              loading: () => const LoadingSkeletonCard(),
              error: (_, __) => const Text('Error loading mortality'),
              data: (f) => Row(
                children: [
                  Text("${f.mortalityRate.toStringAsFixed(1)}%", style: AppTypography.displayStat),
                  const SizedBox(width: 8),
                  const StatusChip(label: "-0.3% from avg", status: ChipStatus.active),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: _MortalityBarChart(batchId: batch.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdownCard(WidgetRef ref, AsyncValue<BatchFinancials> financialsAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Expense Breakdown", style: AppTypography.headlineMd),
            const SizedBox(height: 24),
            financialsAsync.when(
              loading: () => const LoadingSkeletonCard(),
              error: (_, __) => const Text('Error loading expenses'),
              data: (f) {
                final breakdown = f.categoryBreakdown;
                if (breakdown.isEmpty) return const Center(child: Text('No expenses recorded'));
                
                final sortedEntries = breakdown.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                
                final maxAmount = sortedEntries.isNotEmpty ? sortedEntries.first.value : 1.0;

                return Column(
                  children: sortedEntries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExpenseBarRow(
                      category: e.key.name.toUpperCase(),
                      amount: e.value,
                      maxAmount: maxAmount,
                      barColor: _getCategoryColor(e.key),
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.feed: return AppColors.primary;
      case ExpenseCategory.birds: return AppColors.secondary;
      case ExpenseCategory.medicine: return AppColors.error;
      case ExpenseCategory.labor: return Colors.blue;
      default: return Colors.grey;
    }
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final points = snapshot.data!;
        
        // Use dummy data for demonstration if empty
        final spots = points.isEmpty ? [
          const FlSpot(0, 0.05),
          const FlSpot(7, 0.2),
          const FlSpot(14, 0.5),
          const FlSpot(21, 1.1),
          const FlSpot(28, 1.8),
          const FlSpot(35, 2.4),
        ] : points.map((p) => FlSpot(p.day.toDouble(), p.weightKg)).toList();

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
              getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.surfaceContainerHigh, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.0)],
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
                        strokeColor: Colors.white
                      );
                    }
                    return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                  },
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.primary,
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                  '${s.y.toStringAsFixed(2)} kg\nDay ${s.x.toInt()}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                )).toList(),
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final breakdown = snapshot.data!;
        
        // Calculate average for color coding
        final avg = breakdown.isEmpty ? 0.0 : breakdown.fold<int>(0, (sum, w) => sum + w.count) / breakdown.length;

        return BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('W${value.toInt()}', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
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
                    color: isAboveAvg ? AppColors.error : AppColors.errorContainer,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
    final expensesAsync = ref.watch(expenseRepositoryProvider).getByBatch(batch.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<ExpenseModel>>(
        future: expensesAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses recorded', style: AppTypography.bodyMd));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: expenses.length,
            itemBuilder: (context, i) {
              final e = expenses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Row(
                  children: [
                    Text(DateFormatter.toDisplayDate(e.date), style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(e.category.name.toUpperCase(), style: AppTypography.labelBold.copyWith(fontSize: 10)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.description ?? 'Expense', style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      NumberFormat.currency(symbol: '$').format(e.amount), 
                      style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/batches/${batch.id}/add-expense'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MortalityTab extends ConsumerWidget {
  final BatchModel batch;
  const _MortalityTab({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(mortalityRepositoryProvider).getByBatch(batch.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<MortalityModel>>(
        future: logsAsync,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final logs = snapshot.data!;
          if (logs.isEmpty) {
            return const Center(child: Text('No mortality logs recorded', style: AppTypography.bodyMd));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Row(
                  children: [
                    Text(DateFormatter.toDisplayDate(log.date), style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 24),
                    Text(
                      "${log.count} Birds", 
                      style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(log.cause ?? 'Unknown cause', style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis),
                    ),
                    if (log.notes != null) const Icon(Icons.note_alt_outlined, size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/batches/${batch.id}/add-mortality'),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.warning_amber_rounded, color: Colors.white),
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final sales = snapshot.data!;
          
          return Column(
            children: [
              if (sales.isNotEmpty) _buildSalesSummary(sales),
              Expanded(
                child: sales.isEmpty 
                  ? const Center(child: Text('No sales recorded yet', style: AppTypography.bodyMd))
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
                            border: Border.all(color: AppColors.surfaceContainerHigh),
                          ),
                          child: Row(
                            children: [
                              Text(DateFormatter.toDisplayDate(s.saleDate), style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${s.birdsSold} Birds Sold", style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                                    Text("\$${s.pricePerKg.toStringAsFixed(2)} per kg", style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(symbol: '$').format(s.totalRevenue), 
                                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
                              ),
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
        onPressed: () => context.push('/home/batches/${batch.id}/add-sale'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.sell_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildSalesSummary(List<SaleModel> sales) {
    final totalBirds = sales.fold<int>(0, (sum, s) => sum + s.birdsSold);
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.totalRevenue);
    final avgPrice = sales.isEmpty ? 0.0 : totalRevenue / sales.fold<double>(0, (sum, s) => sum + (s.birdsSold * s.averageWeightKg));
    
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
          _summaryItem("Total Revenue", NumberFormat.compactCurrency(symbol: '$').format(totalRevenue)),
          _summaryItem("Avg Price/kg", "\$${avgPrice.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
