import 'package:flutter_riverpod/flutter_riverpod.dart';

class QrScannerState {
  final String? scannedValue;
  final bool isProcessing;
  final String? errorMessage;

  const QrScannerState({
    this.scannedValue,
    this.isProcessing = false,
    this.errorMessage,
  });

  QrScannerState copyWith({
    String? scannedValue,
    bool? isProcessing,
    String? errorMessage,
  }) =>
      QrScannerState(
        scannedValue: scannedValue ?? this.scannedValue,
        isProcessing: isProcessing ?? this.isProcessing,
        errorMessage: errorMessage,
      );
}

class QrScannerNotifier extends Notifier<QrScannerState> {
  @override
  QrScannerState build() => const QrScannerState();

  Future<void> onScan(String value) async {
    if (state.isProcessing) return;
    state = state.copyWith(scannedValue: value, isProcessing: true);
    // TODO: resolve destination from scanned QR value via repository
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isProcessing: false);
  }

  void reset() => state = const QrScannerState();
}

final qrScannerProvider = NotifierProvider<QrScannerNotifier, QrScannerState>(
  QrScannerNotifier.new,
);
