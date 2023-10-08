import 'package:bitcoin_icons/bitcoin_icons.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_screen_cubit.dart';

class WalletBalanceView extends StatefulWidget {
  const WalletBalanceView({super.key});

  @override
  State<WalletBalanceView> createState() => _WalletBalanceViewState();
}

class _WalletBalanceViewState extends State<WalletBalanceView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeState>(builder: (context, state) {
      final cubit = context.read<HomeScreenCubit>();

      return state is HomeSuccess
          ? Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BitcoinText(
                          '${cubit.satoshisToBitcoin(state.walletInfo.onChainBalanceSats)}',
                          fontSize: 36,
                        ),
                        const SizedBox(width: 2),
                        const BitcoinText('BTC'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(BitcoinIcons.link),
                        const SizedBox(width: 2),
                        BitcoinText(
                            '${cubit.satoshisToBitcoin(state.walletInfo.onChainBalanceSats)}'),
                        const SizedBox(width: 2),
                        const BitcoinText('BTC'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(BitcoinIcons.lightning_outline),
                        const SizedBox(width: 2),
                        BitcoinText(
                            '${cubit.satoshisToBitcoin(state.walletInfo.outboundCapacitySats)}'),
                        const SizedBox(width: 2),
                        const BitcoinText('BTC'),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  child: state.syncStatus == SyncStatus.success
                      ? IconButton(
                          onPressed: () {
                            cubit.refresh();
                          },
                          icon: const Icon(Icons.refresh),
                        )
                      : const CircularProgressIndicator(),
                )
              ],
            )
          : Container();
    });
  }
}
