import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/ar_provider.dart';
import '../widgets/ar_info_card.dart';
import '../widgets/calibration_widget.dart';

class ArScreen extends ConsumerStatefulWidget {
  const ArScreen({super.key});

  @override
  ConsumerState<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends ConsumerState<ArScreen> {
  UnityWidgetController? _unityController;

  @override
  void dispose() {
    _unityController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(arProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Unity AR view (renders the C# AR navigation scene)
          UnityWidget(
            onUnityCreated: (controller) => _unityController = controller,
            useAndroidViewSurface: true,
          ),

          // Calibrating overlay
          if (state.status == ArStatus.calibrating) const CalibrationWidget(),

          // Loading overlay
          if (state.status == ArStatus.loadingRoute)
            Container(
              color: AppColors.overlay,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLoader(color: AppColors.textOnPrimary),
                  const SizedBox(height: 16),
                  Text(AppStrings.arLaunching, style: const TextStyle(color: AppColors.textOnPrimary)),
                ],
              ),
            ),

          // Error overlay
          if (state.status == ArStatus.error)
            ErrorState(
              message: state.errorMessage ?? '',
              onRetry: state.destinationId != null
                  ? () => ref.read(arProvider.notifier).startNavigation(state.destinationId!)
                  : null,
            ),

          // Info card during navigation
          if (state.status == ArStatus.navigating && state.currentRoute != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: ArInfoCard(route: state.currentRoute!),
            ),

          // Back / stop button
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textOnPrimary),
                style: IconButton.styleFrom(backgroundColor: AppColors.overlay),
                onPressed: () => ref.read(arProvider.notifier).stopNavigation(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
