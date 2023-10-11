import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'open_channel_cubit.dart';

typedef OpenSuccess = Function(
  String title,
  String message,
  BuildContext context,
);

class OpenChannelScreen extends StatelessWidget {
  const OpenChannelScreen({
    super.key,
    required this.walletRepository,
    required this.onChannelOpenSuccess,
  });

  final WalletRepository walletRepository;
  final OpenSuccess onChannelOpenSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OpenChannelCubit>(
      create: (_) => OpenChannelCubit(
        walletRepository: walletRepository,
      ),
      child: _OpenChannelScreenView(onChannelOpenSuccess: onChannelOpenSuccess),
    );
  }
}

class _OpenChannelScreenView extends StatelessWidget {
  const _OpenChannelScreenView({
    required this.onChannelOpenSuccess,
  });
  final OpenSuccess onChannelOpenSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Channel'),
      ),
      body: _OpenChannelForm(onChannelOpenSuccess: onChannelOpenSuccess),
    );
  }
}

class _OpenChannelForm extends StatefulWidget {
  const _OpenChannelForm({required this.onChannelOpenSuccess});
  final OpenSuccess onChannelOpenSuccess;

  @override
  State<_OpenChannelForm> createState() => __OpenChannelFormState();
}

class __OpenChannelFormState extends State<_OpenChannelForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nodeIdController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _counterpartyAmountController =
      TextEditingController();

  @override
  void dispose() {
    _nodeIdController.dispose();
    _ipAddressController.dispose();
    _portController.dispose();
    _amountController.dispose();
    _counterpartyAmountController.dispose();
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
      final cubit = context.read<OpenChannelCubit>();
      cubit.onSubmit(
        nodeId: _nodeIdController.text,
        host: _ipAddressController.text,
        port: int.parse(_portController.text.trim()),
        amountSat: int.parse(_amountController.text.trim()),
        pushToCounterpartySat:
            _counterpartyAmountController.text.trim().isNotEmpty
                ? int.parse(
                    _counterpartyAmountController.text.trim(),
                  )
                : 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OpenChannelCubit, OpenChannelState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          Navigator.of(context).pop();
          widget.onChannelOpenSuccess(
            'Payment Channel Successfully Opened!',
            'Congratulations! 🎉 You\'ve successfully opened a payment channel with Node ID: ${_nodeIdController.text}.',
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
                'Oops! We encountered an issue while trying to open a payment channel. Please try again later.',
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
                    controller: _nodeIdController,
                    labelText: 'Node ID',
                    validator: (value) => _validateField(value, 'Node ID'),
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  WalletTextField(
                    controller: _ipAddressController,
                    labelText: 'IP Address',
                    validator: (value) => _validateField(value, 'IP Address'),
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  WalletTextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    labelText: 'Port',
                    validator: (value) => _validateField(value, 'Port'),
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  WalletTextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    labelText: 'Amount (in sats)',
                    validator: (value) => _validateField(value, 'Amount'),
                    enabled: !isSubmissionInProgress,
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  WalletTextField(
                    controller: _counterpartyAmountController,
                    keyboardType: TextInputType.number,
                    labelText: 'CounterParty Amount (in sats)',
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

// class OpenChannelScreen extends StatefulWidget {
//   const OpenChannelScreen({super.key});

//   @override
//   State<OpenChannelScreen> createState() => _OpenChannelScreenState();
// }

// class _OpenChannelScreenState extends State<OpenChannelScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _nodeIdController = TextEditingController();
//   final TextEditingController _ipAddressController = TextEditingController();
//   final TextEditingController _portController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _counterpartyAmountController =
//       TextEditingController();

//   @override
//   void dispose() {
//     _nodeIdController.dispose();
//     _ipAddressController.dispose();
//     _portController.dispose();
//     _amountController.dispose();
//     _counterpartyAmountController.dispose();
//     super.dispose();
//   }

//   String? _validateField(String? value, String fieldName) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter the $fieldName';
//     }
//     return null;
//   }

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Perform your channel opening logic here
//       // Once completed, you can navigate to the next screen or show a success message.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Open Channel'),
//       ),
      // body: Container( 
      //   padding: const EdgeInsets.all(Spacing.mediumLarge),
      //   child: Form(
      //     key: _formKey,
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [
      //           const SizedBox(height: Spacing.small),
      //           WalletTextField(
      //             controller: _nodeIdController,
      //             labelText: 'Node ID',
      //             validator: (value) => _validateField(value, 'Node ID'),
      //           ),
      //           const SizedBox(height: Spacing.mediumLarge),
      //           WalletTextField(
      //             controller: _ipAddressController,
      //             labelText: 'IP Address',
      //             validator: (value) => _validateField(value, 'IP Address'),
      //           ),
      //           const SizedBox(height: Spacing.mediumLarge),
      //           WalletTextField(
      //             controller: _portController,
      //             keyboardType: TextInputType.number,
      //             labelText: 'Port',
      //             validator: (value) => _validateField(value, 'Port'),
      //           ),
      //           const SizedBox(height: Spacing.mediumLarge),
      //           WalletTextField(
      //             controller: _amountController,
      //             keyboardType: TextInputType.number,
      //             labelText: 'Amount',
      //             validator: (value) => _validateField(value, 'Amount'),
      //           ),
      //           const SizedBox(height: Spacing.mediumLarge),
      //           WalletTextField(
      //             controller: _counterpartyAmountController,
      //             keyboardType: TextInputType.number,
      //             labelText: 'CounterParty Amount',
      //           ),
      //           const SizedBox(height: Spacing.xLarge),
      //           BitcoinElevatedButton(
      //             label: 'Submit',
      //             onPressed: _submitForm,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
//     );
//   }
// }
