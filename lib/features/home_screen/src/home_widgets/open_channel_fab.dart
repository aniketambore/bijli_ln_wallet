import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';

class OpenChannelFAB extends StatelessWidget {
  const OpenChannelFAB({
    super.key,
    required this.animation,
    required this.animationController,
    required this.onOpenChannelTap,
  });
  final Animation<double>? animation;
  final AnimationController? animationController;
  final VoidCallback onOpenChannelTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionBubble(
        animation: animation!,
        onPress: () => animationController!.isCompleted
            ? animationController!.reverse()
            : animationController!.forward(),
        iconColor: BitcoinColors.neutral1,
        backGroundColor: BitcoinColors.black,
        iconData: Icons.add_outlined,
        items: [
          Bubble(
            icon: Icons.edit_outlined,
            iconColor: BitcoinColors.neutral1,
            title: 'ENTER A NODE URI',
            titleStyle: const TextStyle(
              fontSize: FontSize.medium,
              color: BitcoinColors.white,
            ),
            bubbleColor: BitcoinColors.black,
            onPress: () {
              animationController?.reverse();
              onOpenChannelTap();
            },
          ),
          Bubble(
            icon: Icons.qr_code_scanner_outlined,
            iconColor: BitcoinColors.neutral1,
            title: 'SCAN A NODE URI',
            titleStyle: const TextStyle(
              fontSize: FontSize.medium,
              color: BitcoinColors.white,
            ),
            bubbleColor: BitcoinColors.black,
            onPress: () {},
          ),
          Bubble(
            icon: Icons.connect_without_contact_outlined,
            iconColor: BitcoinColors.neutral1,
            title: 'CONNECT TO LSP',
            titleStyle: const TextStyle(
              fontSize: FontSize.medium,
              color: BitcoinColors.white,
            ),
            bubbleColor: BitcoinColors.black,
            onPress: () {},
          ),
        ]);
  }
}
