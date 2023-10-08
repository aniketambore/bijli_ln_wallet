import 'package:auto_size_text/auto_size_text.dart';
import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'send_offchain_dialog_cubit.dart';

typedef SendSuccess = Function(
  String title,
  String message,
  BuildContext context,
);

class SendOffChainDialog extends StatelessWidget {
  const SendOffChainDialog({
    super.key,
    required this.walletRepository,
    required this.onSendSuccess,
    required this.invoice,
  });
  final WalletRepository walletRepository;
  final Invoice invoice;
  final SendSuccess onSendSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendOffChainDialogCubit>(
      create: (_) => SendOffChainDialogCubit(
        walletRepository: walletRepository,
      ),
      child: _SendOffChainDialogView(
        invoice: invoice,
        onSendSuccess: onSendSuccess,
      ),
    );
  }
}

class _SendOffChainDialogView extends StatefulWidget {
  const _SendOffChainDialogView({
    required this.invoice,
    required this.onSendSuccess,
  });
  final Invoice invoice;
  final SendSuccess onSendSuccess;

  @override
  State<_SendOffChainDialogView> createState() =>
      _SendOffChainDialogViewState();
}

class _SendOffChainDialogViewState extends State<_SendOffChainDialogView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _amountFocusNode = FocusNode();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final amount = widget.invoice.amountSat;
    if (amount != 0) {
      _amountController.text = '$amount';
    }
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (int.parse(_amountController.text) != 0) {
      final cubit = context.read<SendOffChainDialogCubit>();
      cubit.onSubmit(widget.invoice.bolt11);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendOffChainDialogCubit, SendOffChainDialogState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          final navigator = Navigator.of(context);
          navigator.pop();
          widget.onSendSuccess(
            'Payment Sent',
            'Congratulations! You have successfully sent ${_amountController.text} sats.',
            context,
          );
          return;
        }

        final hasSubmissionError =
            state.submissionStatus == SubmissionStatus.sendPaymentError;
        if (hasSubmissionError) {
          BijliFlushbar.showFlushbar(
            context,
            message: 'There has been an error while paying this invoice.',
            duration: const Duration(seconds: 3),
          );
        }
      },
      builder: (context, state) {
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;

        return AlertDialog(
          title: _buildRequestPayTextWidget(),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_buildAmount(), _buildDescriptionWidget()],
            ),
          ),
          actions: [
            isSubmissionInProgress
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallButton(
                          text: 'Cancel',
                          callback: () {
                            Navigator.pop(context);
                          }),
                      SmallButton(text: 'Approve', callback: _submitForm),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Widget _buildRequestPayTextWidget() {
    return const Text(
      'You are requested to pay:',
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAmount() {
    if (widget.invoice.amountSat == 0) {
      return Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          focusNode: _amountFocusNode,
          keyboardType: TextInputType.number,
          autocorrect: false,
          decoration: const InputDecoration(labelText: "Amount in sats"),
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Amount is required.";
            }
            final amount = int.tryParse(value!);
            if (amount == null || amount <= 0) {
              return "Amount must be greater than 0 Satoshis.";
            } else if (amount > 1234) {
              return "Amount must be less than 1234 Satoshis.";
            }
            return null;
          },
        ),
      );
    } else {
      return BitcoinText(
        '${_amountController.text} sats',
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w600,
        fontSize: FontSize.mediumLarge,
      );
    }
  }

  Widget _buildDescriptionWidget() {
    final description = widget.invoice.description;

    if (description != null) {
      return description.isNotEmpty
          ? Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
                minWidth: double.infinity,
              ),
              padding: const EdgeInsets.only(top: Spacing.small),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: AutoSizeText(
                    description,
                    textAlign:
                        description.length > 40 && !description.contains("\n")
                            ? TextAlign.start
                            : TextAlign.center,
                  ),
                ),
              ),
            )
          : Container();
    }
    return Container();
  }
}
