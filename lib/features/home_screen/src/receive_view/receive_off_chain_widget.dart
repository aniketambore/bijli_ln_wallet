import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../home_screen_cubit.dart';

class ReceiveOffChainWidget extends StatelessWidget {
  const ReceiveOffChainWidget({
    super.key,
    required this.walletInfo,
  });
  final Wallet walletInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.mediumLarge),
      child: walletInfo.paymentChannelsList.isEmpty
          ? const _NoChannels()
          : walletInfo.inboundCapacitySats == 0
              ? const _NoCapacity()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _AddressHeaderWidget(
                          invoice: walletInfo.bolt11Invoice ?? ''),
                      const SizedBox(height: Spacing.large),
                      _AddressQRWidget(
                        address: walletInfo.bolt11Invoice ?? '',
                        inbound: walletInfo.inboundCapacitySats,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _AddressHeaderWidget extends StatelessWidget {
  const _AddressHeaderWidget({
    required this.invoice,
  });
  final String invoice;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const BitcoinText('BOLT11 Invoice',
            fontSize: 22, fontWeight: FontWeight.w500),
        Row(
          children: [
            _ShareIcon(invoice: invoice),
            _CopyIcon(invoice: invoice),
          ],
        ),
      ],
    );
  }
}

class _ShareIcon extends StatelessWidget {
  const _ShareIcon({
    required this.invoice,
  });
  final String invoice;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: () => Share.share(invoice),
    );
  }
}

class _CopyIcon extends StatelessWidget {
  const _CopyIcon({
    required this.invoice,
  });
  final String invoice;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy_outlined),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: invoice));
        BijliFlushbar.showFlushbar(
          context,
          message: 'Invoice was copied to your clipboard.',
        );
      },
    );
  }
}

class _AddressQRWidget extends StatelessWidget {
  const _AddressQRWidget({
    required this.address,
    required this.inbound,
  });
  final String address;
  final int inbound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompactQRImage(
          data: 'lightning:$address',
          size: 180,
        ),
        const SizedBox(height: Spacing.small),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BitcoinText('Max: $inbound sats'),
            const SizedBox(width: 2),
            const Icon(Icons.info_outline),
          ],
        ),
        const SizedBox(height: Spacing.mediumLarge),
        BitcoinElevatedButton(
          label: 'EDIT REQUEST',
          icon: const Icon(
            Icons.edit_outlined,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return _CreateInvoiceDialog(
                  inbound: inbound,
                  parentContext: context,
                );
              },
            );
          },
        )
      ],
    );
  }
}

class _CreateInvoiceDialog extends StatefulWidget {
  const _CreateInvoiceDialog(
      {required this.inbound, required this.parentContext});
  final int inbound;
  final BuildContext parentContext;

  @override
  State<_CreateInvoiceDialog> createState() => __CreateInvoiceDialogState();
}

class __CreateInvoiceDialogState extends State<_CreateInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final cubit = widget.parentContext.read<HomeScreenCubit>();
      cubit.createInvoice(
        amountSat: int.parse(_amountController.text),
        description: _descriptionController.text,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Create Lightning Invoice",
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                maxLength: 90,
                decoration:
                    const InputDecoration(labelText: "Description (Optional)"),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length > 90) {
                    return "Description must be less than or equal to 90 characters.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Amount in Satoshis"),
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Amount is required.";
                  }
                  final amount = int.tryParse(value!);
                  if (amount == null || amount <= 0) {
                    return "Amount must be greater than 0 Satoshis.";
                  } else if (amount > widget.inbound) {
                    return "Amount must be less than ${widget.inbound} Satoshis.";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SmallButton(
                text: 'Cancel',
                callback: () {
                  Navigator.pop(context);
                }),
            SmallButton(text: 'Ok', callback: _submitForm),
          ],
        )
      ],
    );
  }
}

class _NoChannels extends StatelessWidget {
  const _NoChannels();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ListTile(
        tileColor: BitcoinColors.red,
        textColor: BitcoinColors.white,
        iconColor: BitcoinColors.white,
        trailing: Icon(Icons.block_outlined),
        title: BitcoinText(
          'No Payment Channel',
          textAlign: TextAlign.start,
          fontSize: FontSize.mediumLarge,
          fontWeight: FontWeight.w600,
        ),
        subtitle: BitcoinText(
          'Oops! It seems you don\'t have any open payment channels in the Lightning Network. To start receiving payments, create a payment channel and fund it.',
          textAlign: TextAlign.start,
          fontSize: FontSize.medium,
        ),
      ),
    );
  }
}

class _NoCapacity extends StatelessWidget {
  const _NoCapacity();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ListTile(
        tileColor: BitcoinColors.red,
        textColor: BitcoinColors.white,
        iconColor: BitcoinColors.white,
        trailing: Icon(Icons.block_outlined),
        title: BitcoinText(
          'No Inbound Capacity',
          textAlign: TextAlign.start,
          fontSize: FontSize.mediumLarge,
          fontWeight: FontWeight.w600,
        ),
        subtitle: BitcoinText(
          'Sorry, you currently don\'t have enough inbound capacity in your payment channel to receive funds. Consider rebalancing your channel or opening a new one with sufficient inbound liquidity.',
          textAlign: TextAlign.start,
          fontSize: FontSize.medium,
        ),
      ),
    );
  }
}
