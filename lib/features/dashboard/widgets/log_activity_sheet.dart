import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/mortality_model.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../batch/providers/batch_providers.dart';

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
              const Icon(Icons.auto_awesome_mosaic, size: 14, color: AppColors.outline),
              const SizedBox(width: 4),
              Text(
                'OFFLINE',
                style: AppTypography.labelBold.copyWith(color: AppColors.outline),
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
      onTap: () => setState(() => _selectedAction = id),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
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
                color: isSelected ? color : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : color, size: 24),
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
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.onSurfaceVariant),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text('Log Feed Usage', style: AppTypography.headlineMd),
          const SizedBox(height: 20),
          DropdownButtonFormField<BatchModel>(
            value: _selectedBatch,
            decoration: _inputDecoration('Select Batch', Icons.inventory_2_outlined),
            hint: const Text('Choose active batch...'),
            items: activeBatches.when(
              data: (batches) => batches.map((b) => DropdownMenuItem(value: b, child: Text('Batch #${b.batchNumber}'))).toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
            onChanged: (val) => setState(() => _selectedBatch = val),
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _feedType,
            decoration: _inputDecoration('Feed Type', Icons.layers_outlined),
            hint: const Text('Select feed formulation...'),
            items: ['Starter', 'Grower', 'Finisher', 'Supplement']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => setState(() => _feedType = val),
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Text('Quantity (kg)', style: AppTypography.labelBold),
          const SizedBox(height: 8),
          _buildStepper(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration('Notes (Optional)', Icons.notes),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _quantity >= 5 ? () => setState(() => _quantity -= 5) : null),
          Text('$_quantity kg', style: AppTypography.headlineMd),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _quantity += 5)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBatch == null || _quantity <= 0) return;
    setState(() => _isLoading = true);
    try {
      final expense = ExpenseModel.create(
        batchId: _selectedBatch!.id,
        farmId: _selectedBatch!.farmId,
        amount: 0,
        category: ExpenseCategory.feed,
        description: 'Feed: $_feedType, Qty: $_quantity kg. ${_notesController.text}',
        date: DateTime.now(),
        quantity: _quantity.toDouble(),
        unit: 'kg',
      );
      await ref.read(expenseRepositoryProvider).create(expense);
      ref.invalidate(dashboardSummaryProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          Text('Log Mortality', style: AppTypography.headlineMd),
          const SizedBox(height: 20),
          DropdownButtonFormField<BatchModel>(
            value: _selectedBatch,
            decoration: _inputDecoration('Select Batch', Icons.inventory_2_outlined),
            items: activeBatches.when(
              data: (batches) => batches.map((b) => DropdownMenuItem(value: b, child: Text('Batch #${b.batchNumber}'))).toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
            onChanged: (val) => setState(() => _selectedBatch = val),
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Text('Death Count', style: AppTypography.labelBold),
          const SizedBox(height: 8),
          _buildStepper(),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (val) => _cause = val,
            decoration: _inputDecoration('Cause/Observation', Icons.bug_report_outlined),
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _count > 0 ? () => setState(() => _count--) : null),
          Text('$_count', style: AppTypography.headlineMd),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _count++)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Record Mortality', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBatch == null || _count <= 0) return;
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
          Text('Log Expense', style: AppTypography.headlineMd),
          const SizedBox(height: 20),
          DropdownButtonFormField<BatchModel>(
            value: _selectedBatch,
            decoration: _inputDecoration('Select Batch', Icons.inventory_2_outlined),
            items: activeBatches.when(
              data: (batches) => batches.map((b) => DropdownMenuItem(value: b, child: Text('Batch #${b.batchNumber}'))).toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
            onChanged: (val) => setState(() => _selectedBatch = val),
            validator: (val) => val == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (val) => _amount = double.tryParse(val) ?? 0,
            decoration: _inputDecoration('Amount (\$)', Icons.attach_money),
            validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExpenseCategory>(
            value: _category,
            decoration: _inputDecoration('Category', Icons.category_outlined),
            items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration('Notes', Icons.notes),
            maxLines: 2,
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
          backgroundColor: AppColors.primary, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.bold)),
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
            value: _selectedBatch,
            decoration: _inputDecoration('Select Batch', Icons.inventory_2_outlined),
            items: activeBatches.when(
              data: (batches) => batches.map((b) => DropdownMenuItem(value: b, child: Text('Batch #${b.batchNumber}'))).toList(),
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
            decoration: _inputDecoration('Average Weight (kg)', Icons.monitor_weight_outlined),
            validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0 ? 'Enter valid weight' : null,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Record', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedBatch == null) return;
    setState(() => _isLoading = true);
    try {
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
