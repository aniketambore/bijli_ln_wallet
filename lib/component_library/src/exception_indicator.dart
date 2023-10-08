import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class ExceptionIndicator extends StatelessWidget {
  const ExceptionIndicator({
    super.key,
    this.title,
    this.message,
    this.onTryAgain,
  });

  final String? title;
  final String? message;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 48,
            ),
            const SizedBox(
              height: 48,
            ),
            Text(
              title ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              title ??
                  'There has been an error.\nPlease, check your internet connection and try again later.',
              textAlign: TextAlign.center,
            ),
            if (onTryAgain != null)
              const SizedBox(
                height: 64,
              ),
            if (onTryAgain != null)
              BitcoinElevatedButton(
                label: 'Try Again',
                onPressed: onTryAgain,
                icon: const Icon(
                  Icons.refresh,
                ),
              )
          ],
        ),
      ),
    );
  }
}
