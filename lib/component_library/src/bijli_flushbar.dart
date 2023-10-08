import 'package:another_flushbar/flushbar.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class BijliFlushbar {
  static const top = FlushbarPosition.TOP;

  static Flushbar showFlushbar(
    BuildContext context, {
    String? title,
    Icon? icon,
    bool isDismissible = true,
    String? message,
    Widget? messageWidget,
    String? buttonText,
    FlushbarPosition position = FlushbarPosition.BOTTOM,
    bool Function()? onDismiss,
    Duration duration = const Duration(seconds: 8),
  }) {
    Flushbar? flush;
    flush = Flushbar(
      isDismissible: isDismissible,
      flushbarPosition: position,
      titleText: title == null
          ? null
          : Text(
              title,
              style: const TextStyle(height: 0.0),
            ),
      icon: icon,
      duration: duration == Duration.zero ? null : duration,
      messageText: messageWidget ??
          Text(
            message ?? '',
            style: const TextStyle(
              fontSize: 14,
              letterSpacing: 0.25,
              height: 1.2,
            ),
            textAlign: TextAlign.left,
          ),
      backgroundColor: BitcoinColors.neutral3,
      mainButton: !isDismissible
          ? null
          : TextButton(
              onPressed: () {
                bool dismiss = onDismiss != null ? onDismiss() : true;
                if (dismiss) {
                  flush!.dismiss(true);
                }
              },
              child: Text(
                buttonText ?? 'OK',
                style: const TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.25,
                  height: 1.2,
                ),
              ),
            ),
    )..show(context);

    return flush;
  }

  static void popFlushbars(BuildContext context) {
    Navigator.popUntil(context, (route) {
      return route.settings.name != FLUSHBAR_ROUTE_NAME;
    });
  }
}
