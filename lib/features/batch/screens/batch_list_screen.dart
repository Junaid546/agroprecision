import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/animations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/batch_model.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/empty_state.dart';
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
          heroTag: 'batch_list_fab',
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/home/batches/new');
          },
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
                    activeCount:
                        all.where((b) => b.status == BatchStatus.active).length,
                    completedCount: all
                        .where((b) => b.status == BatchStatus.completed)
                        .length,
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
                  (ctx, i) => FadeInSlide(
                    delay: Duration(milliseconds: i * 50),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RepaintBoundary(
                        child: _BatchCard(batch: filtered[i]),
                      ),
                    ),
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
      return EmptyState(
        title: 'No Batches Yet',
        message:
            'Start tracking your first batch of birds. Tap the button below to begin.',
        actionLabel: 'Start First Batch',
        onAction: () => context.push('/home/batches/new'),
        icon: Icons.inventory_2_outlined,
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
          Container(
              height: 28,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              )),
          const SizedBox(height: 16),
          Row(
              children: List.generate(
                  3,
                  (i) => Container(
                        height: 32,
                        width: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999)),
                      ))),
          const SizedBox(height: 16),
          ...List.generate(
              3,
              (i) => Padding(
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
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Could not load batches', style: AppTypography.headlineMd),
            const SizedBox(height: 8),
            Text(e.toString(),
                style: AppTypography.bodyMd, textAlign: TextAlign.center),
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
          _Chip(
              label: 'All Batches',
              count: allCount,
              value: 'all',
              selected: selected,
              onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(
              label: 'Active',
              count: activeCount,
              value: 'active',
              selected: selected,
              onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(
              label: 'Completed',
              count: completedCount,
              value: 'completed',
              selected: selected,
              onTap: onChanged),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          count > 0 ? '${label.toUpperCase()} \u2022 $count' : label.toUpperCase(),
          style: AppTypography.labelBold.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 12,
            letterSpacing: 1.1,
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(batch.batchNumber,
                                  style: AppTypography.headlineMd.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  )),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 10, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Started ${DateFormatter.toDisplayDate(batch.startDate)}',
                                    style: AppTypography.labelMd
                                        .copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: isActive ? 'ACTIVE' : 'COMPLETED',
                          status: isActive
                              ? ChipStatus.active
                              : ChipStatus.completed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? 'CHICKENS ALIVE' : 'TOTAL HARVEST',
                                  style: AppTypography.labelBold.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 10,
                                      letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 4),
                                aliveAsync.when(
                                  loading: () => Container(height: 32, width: 60, color: AppColors.surfaceContainerHigh),
                                  error: (_, __) => Text('â€”', style: AppTypography.displayStat),
                                  data: (count) => CountUpText(
                                    value: count.toDouble(),
                                    decimalDigits: 0,
                                    style: AppTypography.displayStat.copyWith(fontSize: 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          financialsAsync.when(
                            loading: () => const SizedBox(width: 40, height: 40, child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (f) => CircularProgressRing(
                              percentage: f.performanceScore,
                              label: "PRO",
                              size: 56,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    financialsAsync.when(
                      loading: () => const SizedBox(height: 20),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (f) {
                        final profitPerBird = f.totalSold > 0
                            ? f.netProfit / f.totalSold
                            : f.currentAlive > 0
                                ? f.netProfit / f.currentAlive
                                : 0.0;
                        final isPositive = profitPerBird >= 0;
                        final color = isPositive ? AppColors.primary : AppColors.error;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '\$${profitPerBird.abs().toStringAsFixed(2)} PER BIRD',
                                style: AppTypography.labelBold.copyWith(
                                  color: color,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
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
