import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bitcoin_icons/bitcoin_icons.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

import 'receive_off_chain_widget.dart';
import 'receive_on_chain_widget.dart';

class ReceiveView extends StatelessWidget {
  const ReceiveView({
    super.key,
    required this.walletInfo,
  });
  final Wallet walletInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.mediumLarge),
      child: Card(
        color: BitcoinColors.neutral3,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                labelColor: BitcoinColors.black,
                physics: NeverScrollableScrollPhysics(),
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        Icon(BitcoinIcons.link),
                        SizedBox(width: 2),
                        Text('ON-CHAIN'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(BitcoinIcons.lightning_outline),
                        SizedBox(width: 2),
                        Text('LIGHTNING'),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ReceiveOnChainWidget(address: walletInfo.onChainAddress),
                    ReceiveOffChainWidget(
                      walletInfo: walletInfo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
