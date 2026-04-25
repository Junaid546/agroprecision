import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../models/report_models.dart';

class ReportPdfPreviewScreen extends StatelessWidget {
  final ReportPreviewArgs args;

  const ReportPdfPreviewScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Report Preview'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: PdfPreview(
        build: (_) async => args.bytes,
        pdfFileName: args.filename,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 720,
        padding: const EdgeInsets.all(16),
        scrollViewDecoration: const BoxDecoration(
          color: AppColors.surface,
        ),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        onError: (context, error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to render the report preview.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          );
        },
      ),
    );
  }
}
