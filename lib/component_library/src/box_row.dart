import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class BoxRow extends StatelessWidget {
  const BoxRow({
    super.key,
    required this.title,
    required this.value,
    this.color = BitcoinColors.black,
  });
  final String title;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: color),
        children: [
          BitcoinTextSpan('$title: ', fontWeight: FontWeight.bold),
          BitcoinTextSpan(value, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
