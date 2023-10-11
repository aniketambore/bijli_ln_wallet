import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/features/send_onchain/src/send_onchain_cubit.dart';
import 'package:bijli_ln_wallet/wallet_repository/src/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef SendSuccess = Function(
  String title,
  String message,
  BuildContext context,
);

class SendOnChainScreen extends StatelessWidget {
  const SendOnChainScreen({
    super.key,
    required this.walletRepository,
    required this.onSendSuccess,
  });
  final WalletRepository walletRepository;
  final SendSuccess onSendSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendOnChainCubit>(
      create: (_) => SendOnChainCubit(walletRepository: walletRepository),
      child: _SendOnChainView(onSendSuccess: onSendSuccess),
    );
  }
}

class _SendOnChainView extends StatelessWidget {
  const _SendOnChainView({
    required this.onSendSuccess,
  });
  final SendSuccess onSendSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send To BTC Address'),
      ),
      body: _SendOnChainForm(onSendSuccess: onSendSuccess),
    );
  }
}

class _SendOnChainForm extends StatefulWidget {
  const _SendOnChainForm({
    required this.onSendSuccess,
  });
  final SendSuccess onSendSuccess;

  @override
  State<_SendOnChainForm> createState() => __SendOnChainFormState();
}

class __SendOnChainFormState extends State<_SendOnChainForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _btcAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _btcAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<SendOnChainCubit>();
      cubit.onSubmit(
        address: _btcAddressController.text,
        amountSats: int.parse(_amountController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendOnChainCubit, SendOnChainState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          Navigator.of(context).pop();
          widget.onSendSuccess(
            'Payment Successful!',
            'Congratulations! Your Bitcoin transaction has been sent successfully to the specified address. Your funds are on their way.',
            context,
          );
          return;
        }

        final hasSubmissionError =
            state.submissionStatus == SubmissionStatus.genericError;
        if (hasSubmissionError) {
          BijliFlushbar.showFlushbar(
            context,
            message:
                'Payment Failed: Please check your payment details and try again',
          );
        }
      },
      builder: (context, state) {
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;
        return Container(
          padding: const EdgeInsets.all(Spacing.mediumLarge),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: Spacing.small),
                  WalletTextField(
                    controller: _btcAddressController,
                    labelText: 'Recipient',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the recipient address';
                      }
                      return null;
                    },
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  WalletTextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    labelText: 'Amount (in sats)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amount';
                      }
                      return null;
                    },
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.xLarge),
                  isSubmissionInProgress
                      ? BitcoinElevatedButton.inProgress(label: 'Submit')
                      : BitcoinElevatedButton(
                          label: 'Submit',
                          onPressed: _submitForm,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
