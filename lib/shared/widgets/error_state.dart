import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message = AppStrings.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 72, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Oops!', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(label: AppStrings.retry, onPressed: onRetry, width: 160),
            ],
          ],
        ),
      ),
    );
  }
}
