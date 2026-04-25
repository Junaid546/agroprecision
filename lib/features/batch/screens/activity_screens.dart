import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/mortality_model.dart';
import '../../../data/models/growth_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../providers/batch_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';

// --- SHARED FORM WIDGETS ---

class _ActivityHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ActivityHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType keyboardType;
  final String? hint;

  const _ActivityInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType = TextInputType.number,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.headlineMd.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: AppTypography.headlineMd.copyWith(color: AppColors.outline, fontSize: 18),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const _DatePickerTile({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TRANSACTION DATE', style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      onSurface: AppColors.onSurface,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onDateSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                  style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outline),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- SCREENS ---

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String batchId;
  const AddExpenseScreen({super.key, required this.batchId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.feed;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final farm = ref.read(currentFarmProvider);
      final expense = ExpenseModel.create(
        batchId: widget.batchId,
        farmId: farm!.id,
        amount: amount,
        category: _category,
        description: _descController.text,
        date: _date,
      );
      await ref.read(expenseRepositoryProvider).create(expense);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(widget.batchId));
      ref.invalidate(batchExpensesProvider(widget.batchId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('New Expense', style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ActivityHeader(
              title: 'Batch Expenditure',
              subtitle: 'Track every dollar spent on this production cycle',
              icon: Icons.payments_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: 32),
            _ActivityInputField(
              label: 'AMOUNT',
              controller: _amountController,
              suffix: 'USD',
              hint: '0.00',
            ),
            const SizedBox(height: 24),
            Text('CATEGORY', style: AppTypography.labelBold.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ExpenseCategory.values.map((c) {
                final isSelected = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                    ),
                    child: Text(
                      c.name.toUpperCase(),
                      style: AppTypography.labelBold.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _DatePickerTile(
              selectedDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 24),
            _ActivityInputField(
              label: 'DESCRIPTION (OPTIONAL)',
              controller: _descController,
              keyboardType: TextInputType.text,
              hint: 'e.g. Bulk feed from local supplier',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('RECORD TRANSACTION', style: AppTypography.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMortalityScreen extends ConsumerStatefulWidget {
  final String batchId;
  const AddMortalityScreen({super.key, required this.batchId});

  @override
  ConsumerState<AddMortalityScreen> createState() => _AddMortalityScreenState();
}

class _AddMortalityScreenState extends ConsumerState<AddMortalityScreen> {
  final _countController = TextEditingController();
  final _causeController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _countController.dispose();
    _causeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid count')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final farm = ref.read(currentFarmProvider);
      final record = MortalityModel.create(
        batchId: widget.batchId,
        farmId: farm!.id,
        count: count,
        date: _date,
        cause: _causeController.text.isEmpty ? 'Unknown' : _causeController.text,
      );
      await ref.read(mortalityRepositoryProvider).create(record);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(widget.batchId));
      ref.invalidate(batchMortalityProvider(widget.batchId));
      ref.invalidate(batchAliveCountProvider(widget.batchId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Mortality Report', style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ActivityHeader(
              title: 'Log Casualties',
              subtitle: 'Monitor flock health by recording daily losses',
              icon: Icons.heart_broken_rounded,
              color: AppColors.error,
            ),
            const SizedBox(height: 32),
            _ActivityInputField(
              label: 'NUMBER OF BIRDS',
              controller: _countController,
              suffix: 'DEAD',
              hint: '0',
            ),
            const SizedBox(height: 24),
            _DatePickerTile(
              selectedDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 24),
            _ActivityInputField(
              label: 'PRIMARY SYMPTOMS / CAUSE',
              controller: _causeController,
              keyboardType: TextInputType.text,
              hint: 'e.g. Diarrhea, sudden death, heat',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.error.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('LOG MORTALITY', style: AppTypography.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddSaleScreen extends ConsumerStatefulWidget {
  final String batchId;
  const AddSaleScreen({super.key, required this.batchId});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _countController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _buyerController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _countController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _buyerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final count = int.tryParse(_countController.text);
    final weight = double.tryParse(_weightController.text);
    final price = double.tryParse(_priceController.text);

    if (count == null || weight == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final farm = ref.read(currentFarmProvider);
      final sale = SaleModel.create(
        batchId: widget.batchId,
        farmId: farm!.id,
        birdsSold: count,
        pricePerKg: price,
        averageWeightKg: weight,
        saleDate: _date,
        buyerName: _buyerController.text,
      );
      await ref.read(saleRepositoryProvider).create(sale);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(widget.batchId));
      ref.invalidate(batchSalesProvider(widget.batchId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Finalize Sale', style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ActivityHeader(
              title: 'Market Transaction',
              subtitle: 'Sell birds and record final batch revenue',
              icon: Icons.shopping_cart_rounded,
              color: Colors.orange,
            ),
            const SizedBox(height: 32),
            _ActivityInputField(
              label: 'NUMBER OF BIRDS SOLD',
              controller: _countController,
              suffix: 'QTY',
              hint: '0',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ActivityInputField(
                    label: 'AVG WEIGHT',
                    controller: _weightController,
                    suffix: 'KG',
                    hint: '0.00',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActivityInputField(
                    label: 'PRICE / KG',
                    controller: _priceController,
                    suffix: 'USD',
                    hint: '0.00',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DatePickerTile(
              selectedDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 24),
            _ActivityInputField(
              label: 'BUYER / AGENT NAME',
              controller: _buyerController,
              keyboardType: TextInputType.text,
              hint: 'e.g. Haji Bashir & Co.',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.orange.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('COMPLETE SALE', style: AppTypography.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddGrowthScreen extends ConsumerStatefulWidget {
  final String batchId;
  const AddGrowthScreen({super.key, required this.batchId});

  @override
  ConsumerState<AddGrowthScreen> createState() => _AddGrowthScreenState();
}

class _AddGrowthScreenState extends ConsumerState<AddGrowthScreen> {
  final _weightController = TextEditingController();
  final _sampleController = TextEditingController(text: '10');
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _sampleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weightController.text);
    final sampleSize = int.tryParse(_sampleController.text) ?? 10;
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid weight')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final farm = ref.read(currentFarmProvider);
      final batch = await ref.read(batchRepositoryProvider).getById(widget.batchId);
      
      final record = GrowthModel.create(
        batchId: widget.batchId,
        farmId: farm!.id,
        averageWeightKg: weight,
        sampleSize: sampleSize,
        batchDay: batch?.ageInDays ?? 0,
        date: _date,
      );
      await ref.read(growthRepositoryProvider).create(record);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(batchFinancialsProvider(widget.batchId));
      ref.invalidate(batchGrowthProvider(widget.batchId));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Growth Tracking', style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ActivityHeader(
              title: 'Weekly Sampling',
              subtitle: 'Monitor weight gain to ensure FCR targets are met',
              icon: Icons.show_chart_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),
            _ActivityInputField(
              label: 'AVERAGE SAMPLE WEIGHT',
              controller: _weightController,
              suffix: 'KG',
              hint: '0.00',
            ),
            const SizedBox(height: 24),
            _ActivityInputField(
              label: 'SAMPLE SIZE (BIRDS)',
              controller: _sampleController,
              suffix: 'BIRDS',
              hint: '10',
            ),
            const SizedBox(height: 24),
            _DatePickerTile(
              selectedDate: _date,
              onDateSelected: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('SAVE RECORD', style: AppTypography.headlineMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
