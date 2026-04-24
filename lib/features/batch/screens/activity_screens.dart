import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../core/constants/app_typography.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: Center(
          child: Text('Add Expense Page', style: AppTypography.headlineMd)),
    );
  }
}

class AddMortalityScreen extends ConsumerWidget {
  const AddMortalityScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: Center(
          child: Text('Add Mortality Page', style: AppTypography.headlineMd)),
    );
  }
}

class AddGrowthScreen extends ConsumerWidget {
  const AddGrowthScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: Center(
          child: Text('Add Growth Page', style: AppTypography.headlineMd)),
    );
  }
}

class AddSaleScreen extends ConsumerWidget {
  const AddSaleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body:
          Center(child: Text('Add Sale Page', style: AppTypography.headlineMd)),
    );
  }
}
