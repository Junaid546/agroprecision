import 'dart:async';
import 'dart:typed_data';

import 'package:agro_precision/data/models/farm_model.dart';
import 'package:agro_precision/data/repositories/farm_repository.dart';
import 'package:agro_precision/features/reports/models/report_models.dart';
import 'package:agro_precision/features/reports/providers/report_providers.dart';
import 'package:agro_precision/features/reports/screens/reports_screen.dart';
import 'package:agro_precision/features/reports/services/report_export_assembler.dart';
import 'package:agro_precision/services/calculation_engine.dart';
import 'package:agro_precision/services/pdf_service.dart';
import 'package:agro_precision/shared/providers/app_state_provider.dart';
import 'package:agro_precision/shared/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  final farm = FarmModel(
    id: 'farm-1',
    name: 'Agro Vision Farm',
    ownerName: 'Amina Khan',
    createdAt: DateTime(2026, 4, 1),
    updatedAt: DateTime(2026, 4, 1),
  );

  final summary = FarmSummaryFinancials(
    totalProfit: 1200,
    totalRevenue: 5000,
    totalCost: 3800,
    overallROI: 31.6,
    batchCount: 1,
    avgCostPerBird: 1.9,
  );

  final performanceRows = [
    BatchPerformanceRow(
      batchId: 'batch-1',
      batchNumber: 'BT-001',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 4, 1),
      revenue: 5000,
      costs: 3800,
      netProfit: 1200,
      roi: 31.6,
    ),
  ];

  testWidgets('Generate PDF shows loading state and opens preview route',
      (tester) async {
    final completer = Completer<ReportExportPayload>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentFarmProvider.overrideWith(
            (ref) => TestCurrentFarmNotifier(farm),
          ),
          farmSummaryProvider.overrideWith((ref) async => summary),
          batchPerformanceListProvider.overrideWith(
            (ref) async => performanceRows,
          ),
          reportExportAssemblerProvider.overrideWith(
            (ref) => _FakeReportExportAssembler(completer.future),
          ),
          pdfServiceProvider.overrideWith((ref) => _FakePdfService()),
        ],
        child: MaterialApp.router(
          routerConfig: _buildTestRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate PDF Report'));
    await tester.pump();

    expect(find.text('Preparing PDF...'), findsOneWidget);
    expect(find.text('Financial Reports'), findsOneWidget);

    completer.complete(_buildReportPayload(farm, summary, performanceRows));
    await tester.pumpAndSettle();

    expect(find.text('Preview Screen'), findsOneWidget);
  });

  testWidgets('Generate PDF failure stays on reports screen and shows error',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentFarmProvider.overrideWith(
            (ref) => TestCurrentFarmNotifier(farm),
          ),
          farmSummaryProvider.overrideWith((ref) async => summary),
          batchPerformanceListProvider.overrideWith(
            (ref) async => performanceRows,
          ),
          reportExportAssemblerProvider.overrideWith(
            (ref) => _ThrowingReportExportAssembler(),
          ),
          pdfServiceProvider.overrideWith((ref) => _FakePdfService()),
        ],
        child: MaterialApp.router(
          routerConfig: _buildTestRouter(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate PDF Report'));
    await tester.pumpAndSettle();

    expect(find.text('Financial Reports'), findsOneWidget);
    expect(find.textContaining('Error generating report:'), findsOneWidget);
  });
}

GoRouter _buildTestRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKeyForTest,
    initialLocation: '/home/reports',
    routes: [
      GoRoute(
        path: '/home/reports',
        builder: (context, state) => const ReportsScreen(),
        routes: [
          GoRoute(
            path: 'preview',
            parentNavigatorKey: _rootNavigatorKeyForTest,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Preview Screen')),
            ),
          ),
        ],
      ),
    ],
  );
}

final _rootNavigatorKeyForTest =
    GlobalKey<NavigatorState>(debugLabel: 'test-root');

class TestCurrentFarmNotifier extends CurrentFarmNotifier {
  TestCurrentFarmNotifier(FarmModel? farm) : super(_TestFarmRepository()) {
    state = farm;
  }
}

class _TestFarmRepository extends FarmRepository {
  @override
  Future<List<FarmModel>> getAll() async => [];
}

class _FakeReportExportAssembler implements ReportExportAssembler {
  final Future<ReportExportPayload> result;

  _FakeReportExportAssembler(this.result);

  @override
  Future<ReportExportPayload> buildReport({
    required FarmModel? farm,
    required FarmSummaryFinancials summary,
    required List<BatchPerformanceRow> performanceRows,
  }) {
    return result;
  }
}

class _ThrowingReportExportAssembler implements ReportExportAssembler {
  @override
  Future<ReportExportPayload> buildReport({
    required FarmModel? farm,
    required FarmSummaryFinancials summary,
    required List<BatchPerformanceRow> performanceRows,
  }) async {
    throw Exception('Preview failed');
  }
}

class _FakePdfService implements PDFService {
  @override
  Future<Uint8List> buildFinancialReportBytes({
    required ReportExportPayload report,
  }) async {
    return Uint8List.fromList(<int>[37, 80, 68, 70, 45]);
  }

  @override
  String buildFinancialReportFilename({
    required String farmName,
    DateTime? generatedAt,
  }) {
    return 'farm_report.pdf';
  }
}

ReportExportPayload _buildReportPayload(
  FarmModel farm,
  FarmSummaryFinancials summary,
  List<BatchPerformanceRow> rows,
) {
  return ReportExportPayload(
    farm: farm,
    farmName: farm.name,
    ownerName: farm.ownerName,
    location: farm.location,
    phone: farm.phone,
    generatedAt: DateTime(2026, 4, 25, 9, 30),
    summary: summary,
    batchPerformanceRows: rows,
    batches: const [],
    insights: const ReportFarmInsights(
      totalBirdsPlaced: 0,
      totalBirdsSold: 0,
      totalBirdsAlive: 0,
      totalBirdsDead: 0,
      expenseMix: {},
      topBatch: null,
      weakestBatch: null,
    ),
  );
}
