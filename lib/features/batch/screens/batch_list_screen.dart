import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/batch_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/batch_providers.dart';

class BatchListScreen extends ConsumerStatefulWidget {
  const BatchListScreen({super.key});

  @override
  ConsumerState<BatchListScreen> createState() => _BatchListScreenState();
}

class _BatchListScreenState extends ConsumerState<BatchListScreen> {
  String _filter = 'all'; // 'all' | 'active' | 'completed'

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(allBatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AgroAppBar(),
      body: batchesAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => _buildError(e),
        data: (batches) {
          final filtered = _filterBatches(batches, _filter);
          return _buildContent(batches, filtered);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.push('/home/batches/new'),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  List<BatchModel> _filterBatches(List<BatchModel> all, String filter) {
    switch (filter) {
      case 'active':
        return all.where((b) => b.status == BatchStatus.active).toList();
      case 'completed':
        return all.where((b) => b.status == BatchStatus.completed).toList();
      default:
        return all;
    }
  }

  Widget _buildContent(List<BatchModel> all, List<BatchModel> filtered) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(allBatchesProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // HEADER + FILTER CHIPS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Batches', style: AppTypography.headlineLg),
                  const SizedBox(height: 16),
                  _FilterChips(
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    allCount: all.length,
                    activeCount: all.where((b) => b.status == BatchStatus.active).length,
                    completedCount: all.where((b) => b.status == BatchStatus.completed).length,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // BATCH LIST OR EMPTY STATE
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(_filter, all.isEmpty),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BatchCard(batch: filtered[i]),
                  ),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter, bool isCompletelyEmpty) {
    if (isCompletelyEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.onSurfaceVariant, size: 40),
              ),
              const SizedBox(height: 20),
              Text('No Batches Yet',
                style: AppTypography.headlineMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your first batch of birds.\nTap the + button to begin.',
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Start First Batch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.push('/home/batches/new'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off_rounded,
            color: AppColors.onSurfaceVariant, size: 48),
          const SizedBox(height: 16),
          Text(
            'No ${filter == 'active' ? 'active' : 'completed'} batches',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _filter = 'all'),
            child: Text('Show all batches',
              style: AppTypography.bodyMd.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(height: 28, width: 100, decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          )),
          const SizedBox(height: 16),
          Row(children: List.generate(3, (i) => Container(
            height: 32, width: 80, margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999)),
          ))),
          const SizedBox(height: 16),
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LoadingSkeleton.skeletonCard(),
          )),
        ],
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Could not load batches', style: AppTypography.headlineMd),
            const SizedBox(height: 8),
            Text(e.toString(), style: AppTypography.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(allBatchesProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final int allCount;
  final int activeCount;
  final int completedCount;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(label: 'All Batches', count: allCount, value: 'all', selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(label: 'Active', count: activeCount, value: 'active', selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(label: 'Completed', count: completedCount, value: 'completed', selected: selected, onTap: onChanged),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int count;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _Chip({
    required this.label,
    required this.count,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: AppTypography.labelBold.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _BatchCard extends ConsumerWidget {
  final BatchModel batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliveAsync = ref.watch(batchAliveCountProvider(batch.id));
    final financialsAsync = ref.watch(batchFinancialsProvider(batch.id));
    final isActive = batch.status == BatchStatus.active;

    return GestureDetector(
      onTap: () => context.push('/home/batches/${batch.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP ACCENT LINE
              Container(
                height: 3,
                color: isActive
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerHigh,
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(batch.batchNumber, style: AppTypography.headlineMd),
                        const Spacer(),
                        StatusChip(
                          label: isActive ? 'Active' : 'Completed',
                          status: isActive ? ChipStatus.active : ChipStatus.completed,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                          size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Started ${DateFormatter.toDisplayDate(batch.startDate)}',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? 'Chickens Alive' : 'Total Harvest',
                                  style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                aliveAsync.when(
                                  loading: () => Container(
                                    height: 32, width: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  error: (_, __) => Text('—', style: AppTypography.displayStat),
                                  data: (count) => Text(
                                    NumberFormat('#,###').format(count),
                                    style: AppTypography.displayStat,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          financialsAsync.when(
                            loading: () => const SizedBox(
                              width: 64, height: 64,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surfaceContainerHigh,
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (f) => CircularProgressRing(
                              percentage: f.performanceScore,
                              label: "Performance",
                              size: 64,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    financialsAsync.when(
                      loading: () => Container(
                        height: 20, width: 140,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (f) {
                        final profitPerBird = f.totalSold > 0
                            ? f.netProfit / f.totalSold
                            : f.currentAlive > 0
                                ? f.netProfit / f.currentAlive
                                : 0.0;
                        final isPositive = profitPerBird >= 0;
                        final color = isPositive ? AppColors.primary : AppColors.error;

                        return Row(
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up_rounded : Icons.money_off_rounded,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${isActive ? 'Est.' : 'Actual'} \$${profitPerBird.abs().toStringAsFixed(2)} per bird ',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isActive ? 'Profit projection' : 'Final profit',
                                    style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
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
            ],
          ),
        ),
      ),
    );
  }
}
