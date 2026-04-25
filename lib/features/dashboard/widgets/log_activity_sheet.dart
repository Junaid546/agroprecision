import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/mortality_model.dart';
import '../../../data/models/growth_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../batch/providers/batch_providers.dart';
import '../../shed_control/providers/shed_control_providers.dart';

class LogActivitySheet extends ConsumerStatefulWidget {
  const LogActivitySheet({super.key});

  @override
  ConsumerState<LogActivitySheet> createState() => _LogActivitySheetState();
}

class _LogActivitySheetState extends ConsumerState<LogActivitySheet> {
  String _selectedAction = 'feed';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildActionGrid(),
              const SizedBox(height: 32),
              _buildSelectedForm(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            Text('Log Daily Activity', style: AppTypography.headlineMd),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_mosaic,
                  size: 14, color: AppColors.outline),
              const SizedBox(width: 4),
              Text(
                'OFFLINE',
                style:
                    AppTypography.labelBold.copyWith(color: AppColors.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionTile(
          id: 'expense',
          label: 'Add Expense',
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.green.shade700,
        ),
        _buildActionTile(
          id: 'deaths',
          label: 'Log Deaths',
          icon: Icons.warning_rounded,
          color: Colors.pink.shade600,
        ),
        _buildActionTile(
          id: 'feed',
          label: 'Add Feed',
          icon: Icons.eco_rounded,
          color: Colors.green.shade600,
        ),
        _buildActionTile(
          id: 'growth',
          label: 'Record Growth',
          icon: Icons.trending_up_rounded,
          color: Colors.amber.shade700,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _selectedAction == id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedAction = id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelBold.copyWith(
                color: isSelected ? color : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedForm() {
    final activeBatchesAsync = ref.watch(activeBatchesProvider);

    return activeBatchesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (batches) {
        if (batches.isEmpty) {
          return _buildNoActiveBatchesState();
        }

        switch (_selectedAction) {
          case 'feed':
            return const _AddFeedForm();
          case 'deaths':
            return const _LogDeathsForm();
          case 'expense':
            return const _AddExpenseForm();
          case 'growth':
            return const _RecordGrowthForm();
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildNoActiveBatchesState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('No Active Batches', style: AppTypography.headlineMd),
          const SizedBox(height: 8),
          Text(
            'You need an active batch to log activities like feeding, mortality, or expenses.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/home/batches/new');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create New Batch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFeedForm extends ConsumerStatefulWidget {
  const _AddFeedForm();
  @override
  ConsumerState<_AddFeedForm> createState() => _AddFeedFormState();
}

class _AddFeedFormState extends ConsumerState<_AddFeedForm> {
  final _formKey = GlobalKey<FormState>();
  BatchModel? _selectedBatch;
  String? _feedType;
  int _quantity = 0;
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBatch = ref.read(autoSelectedBatchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeBatches = ref.watch(activeBatchesProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text('Log Feed Usage', style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 24),
          
          // BATCH SELECTION
          Text('SELECT ACTIVE BATCH', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          activeBatches.when(
            data: (batches) => SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final b = batches[index];
                  final isSelected = _selectedBatch?.id == b.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBatch = b),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('BATCH #${b.batchNumber}',
                            style: AppTypography.labelBold.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            )),
                          Text('Day ${b.ageInDays}',
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                            )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading batches'),
          ),
          
          const SizedBox(height: 24),

          // FEED TYPE SELECTION
          Text('FEED FORMULATION', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Starter', 'Grower', 'Finisher', 'Supplement'].map((type) {
              final isSelected = _feedType == type;
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (val) => setState(() => _feedType = type),
                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.labelBold.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          
          Text('QUANTITY (KG)', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildStepper(),
          
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration('NOTES (OPTIONAL)', Icons.notes_rounded),
            maxLines: 2,
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _quantity >= 5
                ? () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _quantity -= 5;
                      _quantityController.text = _quantity.toString();
                    });
                  }
                : null,
          ),
          Expanded(
            child: TextField(
              controller: _quantityController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.headlineMd,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                suffixText: 'kg',
                suffixStyle: TextStyle(fontSize: 14, color: AppColors.outline),
              ),
              onChanged: (val) {
                final n = int.tryParse(val) ?? 0;
                setState(() => _quantity = n);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _quantity += 5;
                _quantityController.text = _quantity.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Entry',
                style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _selectedBatch == null ||
        _quantity <= 0) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final expense = ExpenseModel.create(
        batchId: _selectedBatch!.id,
        farmId: _selectedBatch!.farmId,
        amount: 0,
        category: ExpenseCategory.feed,
        description:
            'Feed: $_feedType, Qty: $_quantity kg. ${_notesController.text}',
        date: DateTime.now(),
        quantity: _quantity.toDouble(),
        unit: 'kg',
      );
      await ref.read(expenseRepositoryProvider).create(expense);
      await ref.read(inventoryFlowServiceProvider).consumeFeedExpense(
            expense,
            shedId: _selectedBatch!.shedId,
          );
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(_selectedBatch!.id));
      ref.invalidate(batchExpensesProvider(_selectedBatch!.id));
      ref.invalidate(farmInventoryProvider);
      ref.invalidate(lowStockItemsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _LogDeathsForm extends ConsumerStatefulWidget {
  const _LogDeathsForm();
  @override
  ConsumerState<_LogDeathsForm> createState() => _LogDeathsFormState();
}

class _LogDeathsFormState extends ConsumerState<_LogDeathsForm> {
  final _formKey = GlobalKey<FormState>();
  BatchModel? _selectedBatch;
  int _count = 0;
  final _countController = TextEditingController(text: '0');
  String? _cause;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBatch = ref.read(autoSelectedBatchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeBatches = ref.watch(activeBatchesProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              Text('Log Mortality', style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 24),

          // BATCH SELECTION
          Text('SELECT ACTIVE BATCH', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          activeBatches.when(
            data: (batches) => SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final b = batches[index];
                  final isSelected = _selectedBatch?.id == b.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBatch = b),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.error : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.error : AppColors.surfaceContainerHigh,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('BATCH #${b.batchNumber}',
                            style: AppTypography.labelBold.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            )),
                          Text('Day ${b.ageInDays}',
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                            )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading batches'),
          ),
          
          const SizedBox(height: 24),
          Text('DEATH COUNT', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildStepper(),
          const SizedBox(height: 24),
          TextFormField(
            onChanged: (val) => _cause = val,
            decoration: _inputDecoration(
                'CAUSE/OBSERVATION', Icons.bug_report_outlined),
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _count > 0
                ? () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _count--;
                      _countController.text = _count.toString();
                    });
                  }
                : null,
          ),
          Expanded(
            child: TextField(
              controller: _countController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.headlineMd,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) {
                final n = int.tryParse(val) ?? 0;
                setState(() => _count = n);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _count++;
                _countController.text = _count.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Record Mortality',
                style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _selectedBatch == null ||
        _count <= 0) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final log = MortalityModel.create(
        batchId: _selectedBatch!.id,
        farmId: _selectedBatch!.farmId,
        count: _count,
        date: DateTime.now(),
        cause: _cause,
      );
      await ref.read(mortalityRepositoryProvider).create(log);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(_selectedBatch!.id));
      ref.invalidate(batchMortalityProvider(_selectedBatch!.id));
      ref.invalidate(batchAliveCountProvider(_selectedBatch!.id));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _AddExpenseForm extends ConsumerStatefulWidget {
  const _AddExpenseForm();
  @override
  ConsumerState<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<_AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  BatchModel? _selectedBatch;
  double _amount = 0;
  ExpenseCategory _category = ExpenseCategory.other;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBatch = ref.read(autoSelectedBatchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeBatches = ref.watch(activeBatchesProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text('Log Expense', style: AppTypography.headlineMd),
            ],
          ),
          const SizedBox(height: 24),

          // BATCH SELECTION
          Text('SELECT ACTIVE BATCH', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          activeBatches.when(
            data: (batches) => SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final b = batches[index];
                  final isSelected = _selectedBatch?.id == b.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBatch = b),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('BATCH #${b.batchNumber}',
                            style: AppTypography.labelBold.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            )),
                          Text('Day ${b.ageInDays}',
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                            )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading batches'),
          ),

          const SizedBox(height: 24),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (val) => _amount = double.tryParse(val) ?? 0,
            decoration: _inputDecoration('AMOUNT (\$)', Icons.attach_money_rounded),
            style: AppTypography.headlineMd,
            validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                ? 'Enter valid amount'
                : null,
          ),
          const SizedBox(height: 24),
          Text('CATEGORY', 
            style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.values.map((c) {
              final isSelected = _category == c;
              return FilterChip(
                label: Text(c.name.toUpperCase()),
                selected: isSelected,
                onSelected: (val) => setState(() => _category = c),
                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.labelBold.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                  fontSize: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration('NOTES', Icons.notes_rounded),
            maxLines: 2,
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Expense',
                style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBatch == null) return;
    setState(() => _isLoading = true);
    try {
      final expense = ExpenseModel.create(
        batchId: _selectedBatch!.id,
        farmId: _selectedBatch!.farmId,
        amount: _amount,
        category: _category,
        description: _notesController.text,
        date: DateTime.now(),
      );
      await ref.read(expenseRepositoryProvider).create(expense);
      ref.invalidate(dashboardSummaryProvider);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _RecordGrowthForm extends ConsumerStatefulWidget {
  const _RecordGrowthForm();
  @override
  ConsumerState<_RecordGrowthForm> createState() => _RecordGrowthFormState();
}

class _RecordGrowthFormState extends ConsumerState<_RecordGrowthForm> {
  final _formKey = GlobalKey<FormState>();
  BatchModel? _selectedBatch;
  double _weight = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBatch = ref.read(autoSelectedBatchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeBatches = ref.watch(activeBatchesProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Record Growth', style: AppTypography.headlineMd),
          const SizedBox(height: 20),
          DropdownButtonFormField<BatchModel>(
            initialValue: _selectedBatch,
            decoration:
                _inputDecoration('Select Batch', Icons.inventory_2_outlined),
            items: activeBatches.when(
              data: (batches) => batches
                  .map((b) => DropdownMenuItem(
                      value: b, child: Text('Batch #${b.batchNumber}')))
                  .toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
            onChanged: (val) => setState(() => _selectedBatch = val),
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) => _weight = double.tryParse(val) ?? 0,
            decoration: _inputDecoration(
                'Average Weight (kg)', Icons.monitor_weight_outlined),
            validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                ? 'Enter valid weight'
                : null,
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Record',
                style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBatch == null) return;
    setState(() => _isLoading = true);
    try {
      final day = DateTime.now().difference(_selectedBatch!.startDate).inDays;
      final growth = GrowthModel.create(
        batchId: _selectedBatch!.id,
        farmId: _selectedBatch!.farmId,
        averageWeightKg: _weight,
        sampleSize: 10, // Default sample size
        batchDay: day < 0 ? 0 : day,
        date: DateTime.now(),
      );
      await ref.read(growthRepositoryProvider).create(growth);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(_selectedBatch!.id));
      ref.invalidate(batchGrowthProvider(_selectedBatch!.id));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
