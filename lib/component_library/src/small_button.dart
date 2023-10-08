import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

import 'themes/font_size.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    required this.text,
    required this.callback,
    this.backgroundColor = BitcoinColors.white,
    this.labelColor = BitcoinColors.black,
    this.disabled = false,
  });

  final String text;
  final bool disabled;
  final Color? backgroundColor;
  final Color? labelColor;

  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: !disabled ? callback : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(80, 30),
        backgroundColor: backgroundColor,
        foregroundColor:
            disabled ? BitcoinColors.neutral6 : BitcoinColors.black,
        side: const BorderSide(width: 1.0, color: BitcoinColors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 5,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: FontSize.small,
            color: labelColor,
          ),
        ),
      ),
    );
  }
}
