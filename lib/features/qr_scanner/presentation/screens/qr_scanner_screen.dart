import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/qr_scanner_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScannerProvider);

    ref.listen(qrScannerProvider, (_, next) {
      if (next.scannedValue != null && !next.isProcessing) {
        // TODO: navigate to AR with scanned destination
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.qrScanTitle),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue != null) {
                ref.read(qrScannerProvider.notifier).onScan(barcode!.rawValue!);
              }
            },
          ),
          _ScanOverlay(),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              state.scannedValue ?? AppStrings.qrScanInstruction,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          if (state.isProcessing)
            Container(
              color: AppColors.overlay,
              child: const Center(child: CircularProgressIndicator(color: AppColors.textOnPrimary)),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
