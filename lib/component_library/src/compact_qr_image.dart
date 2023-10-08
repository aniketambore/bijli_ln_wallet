import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

var _versionsToMaxCharacters = [
  17,
  32,
  53,
  78,
  106,
  134,
  154,
  192,
  230,
  271,
  321,
  367,
  425,
  458,
  520,
  586,
  644,
  718,
  792,
  858,
  929,
  1003,
  1091,
  1171,
  1273,
  1367,
  1465,
  1528,
  1628,
  1732,
  1840,
  1952,
  2068,
  2188,
  2303,
  2431,
  2563,
  2699,
  2809,
  2953
];

class CompactQRImage extends StatelessWidget {
  final String data;
  final double? size;

  const CompactQRImage({Key? key, required this.data, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      version: _calculateVersion(),
      data: data.toUpperCase(),
      size: size,
      embeddedImage: const AssetImage(
        'assets/bijli_qr_logo.png',
      ),
    );
  }

  int _calculateVersion() {
    int index;
    for (index = 0; index < _versionsToMaxCharacters.length; ++index) {
      if (_versionsToMaxCharacters[index] > data.length) {
        break;
      }
    }
    return index + 1;
  }
}
