import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

typedef InvoiceParsed = Function(Invoice invoiceInfo);

class SendOffChainScreen extends StatefulWidget {
  const SendOffChainScreen({
    super.key,
    required this.walletRepository,
    required this.onInvoiceParsedSuccess,
  });
  final WalletRepository walletRepository;
  final InvoiceParsed onInvoiceParsedSuccess;

  @override
  State<SendOffChainScreen> createState() => _SendOffChainScreenState();
}

class _SendOffChainScreenState extends State<SendOffChainScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceController = TextEditingController();

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter the $fieldName';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      try {
        final invoice = widget.walletRepository
            .decodeBolt11Invoice(_invoiceController.text);
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => widget.onInvoiceParsedSuccess(invoice),
        );
      } catch (e) {
        BijliFlushbar.showFlushbar(
          context,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paste Invoice'),
      ),
      body: Container(
        padding: const EdgeInsets.all(Spacing.mediumLarge),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BitcoinText(
                  "Enter payee information.",
                  textAlign: TextAlign.start,
                  fontSize: FontSize.mediumLarge,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: Spacing.xLarge),
                WalletTextField(
                  controller: _invoiceController,
                  labelText: 'Invoice or ID',
                  validator: (value) => _validateField(value, 'Invoice'),
                  textInputAction: TextInputAction.done,
                  autoCorrect: false,
                ),
                const SizedBox(height: Spacing.mediumLarge),
                const BitcoinText(
                  'Enter an invoice, a node ID or a Lightning address.',
                  fontSize: FontSize.medium,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // padding: const EdgeInsets.all(Spacing.mediumLarge),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  Spacing.mediumLarge,
              left: Spacing.mediumLarge,
              right: Spacing.mediumLarge,
            ),
            child: BitcoinElevatedButton(
              label: 'Continue ',
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }
}
