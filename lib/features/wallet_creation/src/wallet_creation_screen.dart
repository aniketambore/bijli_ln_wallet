import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

class WalletCreationScreen extends StatefulWidget {
  const WalletCreationScreen({
    super.key,
    required this.walletRepository,
    required this.onCreateWalletSuccess,
    required this.onRecoverWalletTap,
  });
  final WalletRepository walletRepository;
  final VoidCallback onCreateWalletSuccess;
  final VoidCallback onRecoverWalletTap;

  @override
  State<WalletCreationScreen> createState() => _WalletCreationScreenState();
}

class _WalletCreationScreenState extends State<WalletCreationScreen> {
  bool isSubmissionInProgress = false;

  Future<void> onCreateWalletSubmit() async {
    setState(() => isSubmissionInProgress = true);
    try {
      await widget.walletRepository.createOrRecoverWallet();
      widget.onCreateWalletSuccess();
    } catch (e) {
      setState(() => isSubmissionInProgress = false);
      BijliFlushbar.showFlushbar(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTitle(),
            const SizedBox(height: Spacing.xxLarge),
            buildButton(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: Spacing.large),
        child: const BitcoinText(
          "Your wallet, your coins\n100% open-source & open-design",
          fontSize: FontSize.small,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Column(
      children: [
        Image.asset(
          'assets/bijli.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: Spacing.large),
        const BitcoinText(
          "Bitcoin wallet",
          fontSize: FontSize.xLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: Spacing.small),
        const BitcoinText(
          "A simple bitcoin wallet for your enjoyment.",
          fontSize: FontSize.large,
        )
      ],
    );
  }

  Widget buildButton() {
    return Column(
      children: [
        isSubmissionInProgress
            ? BitcoinElevatedButton.inProgress(
                label: 'Create a new wallet',
                fontSize: FontSize.mediumLarge,
                height: 60,
              )
            : BitcoinElevatedButton(
                label: 'Create a new wallet',
                onPressed: () => onCreateWalletSubmit(),
                backgroundColor: BitcoinColors.orange,
                fontSize: FontSize.mediumLarge,
                height: 60,
                textPadding: const EdgeInsets.symmetric(
                  vertical: 19,
                  horizontal: 20,
                ),
              ),
        const SizedBox(height: Spacing.large),
        isSubmissionInProgress
            ? const Text('Creating Wallet...')
            : BitcoinTextButton(
                label: 'Restore existing wallet',
                onPressed: () {},
                fontSize: FontSize.mediumLarge,
                color: BitcoinColors.orange,
              ),
      ],
    );
  }
}
