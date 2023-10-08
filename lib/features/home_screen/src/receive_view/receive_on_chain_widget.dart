import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveOnChainWidget extends StatelessWidget {
  const ReceiveOnChainWidget({
    super.key,
    required this.address,
  });
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.mediumLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AddressHeaderWidget(address: address),
          const SizedBox(height: Spacing.large),
          AddressQRWidget(address: address),
        ],
      ),
    );
  }
}

class AddressHeaderWidget extends StatelessWidget {
  const AddressHeaderWidget({
    super.key,
    required this.address,
  });
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const BitcoinText('Deposit Address',
            fontSize: 22, fontWeight: FontWeight.w500),
        Row(
          children: [
            _ShareIcon(address: address),
            _CopyIcon(address: address),
          ],
        ),
      ],
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.address,
  });
  final String address;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: () => Share.share(address),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  const _CopyIcon({
    required this.address,
  });
  final String address;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy_outlined),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: address));
        BijliFlushbar.showFlushbar(
          context,
          message: 'Deposit address was copied to your clipboard.',
        );
      },
    );
  }
}

class AddressQRWidget extends StatelessWidget {
  const AddressQRWidget({
    super.key,
    required this.address,
  });
  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompactQRImage(
          data: 'bitcoin:$address',
          size: 180,
        ),
        const SizedBox(height: Spacing.xLarge),
        BitcoinText(
          address,
        )
      ],
    );
  }
}
