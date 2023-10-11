import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';

class MakePaymentFAB extends StatelessWidget {
  const MakePaymentFAB({
    super.key,
    required this.animation,
    required this.animationController,
    required this.onSendOffChainTap,
    required this.onSendOnChainTap,
  });
  final Animation<double>? animation;
  final AnimationController? animationController;
  final VoidCallback onSendOffChainTap;
  final VoidCallback onSendOnChainTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionBubble(
      animation: animation!,
      onPress: () => animationController!.isCompleted
          ? animationController!.reverse()
          : animationController!.forward(),
      iconColor: BitcoinColors.neutral1,
      backGroundColor: BitcoinColors.black,
      iconData: Icons.call_made_outlined,
      items: [
        Bubble(
          icon: Icons.paste_outlined,
          iconColor: BitcoinColors.neutral1,
          title: 'PASTE AN INVOICE',
          titleStyle: const TextStyle(
            fontSize: FontSize.medium,
            color: BitcoinColors.white,
          ),
          bubbleColor: BitcoinColors.black,
          onPress: () {
            animationController?.reverse();
            onSendOffChainTap();
          },
        ),
        Bubble(
          icon: Icons.currency_bitcoin_outlined,
          iconColor: BitcoinColors.neutral1,
          title: 'SEND TO BTC ADDRESS',
          titleStyle: const TextStyle(
            fontSize: FontSize.medium,
            color: BitcoinColors.white,
          ),
          bubbleColor: BitcoinColors.black,
          onPress: () {
            animationController?.reverse();
            onSendOnChainTap();
          },
        ),
        Bubble(
          icon: Icons.qr_code_scanner_outlined,
          iconColor: BitcoinColors.neutral1,
          title: 'SCAN AND PAY',
          titleStyle: const TextStyle(
            fontSize: FontSize.medium,
            color: BitcoinColors.white,
          ),
          bubbleColor: BitcoinColors.black,
          onPress: () {},
        ),
      ],
    );
  }
}
