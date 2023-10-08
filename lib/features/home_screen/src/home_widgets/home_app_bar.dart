import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.onWalletInfoTap,
  });
  final VoidCallback onWalletInfoTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Image.asset(
        'assets/bijli.png',
        width: 40,
        height: 40,
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            color: BitcoinColors.black,
          ), // Three-dot icon
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                onTap: onWalletInfoTap,
                child: const Text('Wallet Info'),
              ),
              const PopupMenuItem(
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                child: Text('About / Help'),
              ),
            ];
          },
        ),
      ],
    );
  }
}
