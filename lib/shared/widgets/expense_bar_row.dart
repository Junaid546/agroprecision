import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';

class ExpenseBarRow extends StatefulWidget {
  final String category;
  final double amount;
  final double maxAmount;
  final Color barColor;

  const ExpenseBarRow({
    super.key,
    required this.category,
    required this.amount,
    required this.maxAmount,
    required this.barColor,
  });

  @override
  State<ExpenseBarRow> createState() => _ExpenseBarRowState();
}

class _ExpenseBarRowState extends State<ExpenseBarRow> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _isMounted = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = widget.maxAmount > 0 
        ? (widget.amount / widget.maxAmount).clamp(0.0, 1.0) 
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.barColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 80,
            child: Text(
              widget.category,
              style: AppTypography.bodyMd,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _isMounted ? percentage : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: widget.barColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            CurrencyFormatter.format(widget.amount),
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
