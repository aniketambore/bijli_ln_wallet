import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class CircleWidget extends StatelessWidget {
  const CircleWidget({
    super.key,
    required this.borderColor,
    required this.bgColor,
    this.size,
    this.iconData,
    this.borderWidth,
  });

  final Color borderColor;
  final Color bgColor;
  final double? size;
  final IconData? iconData;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? 34,
      width: size ?? 34,
      decoration: ShapeDecoration(
        color: bgColor,
        shape: CircleBorder(
          side: BorderSide(
            color: borderColor,
            width: borderWidth ?? 2,
          ),
        ),
      ),
      child: iconData != null && size != null
          ? Icon(
              iconData,
              size: size! - 5,
              color: BitcoinColors.neutral3Dark,
            )
          : null,
    );
  }
}
