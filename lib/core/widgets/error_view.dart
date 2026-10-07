import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../errors/failures.dart';

class ErrorView extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;
  final String? customMessage;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.customMessage,
  });

  bool get isNetworkError {
    if (error is NetworkFailure) return true;
    final message = error.toString().toLowerCase();
    return message.contains('интернэт') ||
        message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOffline = isNetworkError;

    final title = isOffline
        ? 'Интернэт холболтгүй байна'
        : 'Алдаа гарлаа';

    final message = customMessage ??
        (error is Failure
            ? (error as Failure).message
            : error?.toString() ?? 'Үл мэдэгдэх алдаа гарлаа.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isOffline ? AppColors.warning : AppColors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 48,
                color: isOffline ? AppColors.warning : AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Дахин оролдох'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
