import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';

import '../home_screen_cubit.dart';

class Payments extends StatefulWidget {
  const Payments({
    super.key,
    required this.paymentsList,
  });
  final List<PaymentDetails> paymentsList;

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  @override
  Widget build(BuildContext context) {
    return widget.paymentsList.isEmpty
        ? const Center(
            child: BitcoinText(
              'This is where all the transactions are listed.',
              textAlign: TextAlign.start,
              fontWeight: FontWeight.w500,
              fontSize: FontSize.mediumLarge,
            ),
          )
        : ListView.builder(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: widget.paymentsList.length,
            itemBuilder: (context, index) {
              final paymentDetails = widget.paymentsList[index];
              return ListTile(
                leading: _buildTileLeading(paymentDetails),
                title: _buildTileTitle(paymentDetails),
                subtitle: _buildSubtitle(paymentDetails),
              );
            },
          );
  }

  Widget _buildTileLeading(PaymentDetails paymentDetails) {
    bool paymentReceived = paymentDetails.direction == PaymentDirection.inbound;
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: paymentReceived ? BitcoinColors.green : BitcoinColors.red,
        shape: const CircleBorder(
          side: BorderSide(color: BitcoinColors.black, width: 2),
        ),
      ),
      child: Center(
        child: Icon(
          paymentReceived
              ? Icons.call_received_outlined
              : Icons.call_made_outlined,
          color: BitcoinColors.white,
        ),
      ),
    );
  }

  Widget _buildTileTitle(PaymentDetails paymentDetails) {
    final cubit = context.read<HomeScreenCubit>();
    String type = paymentDetails.direction == PaymentDirection.inbound
        ? 'Received'
        : 'Sent';
    int amountSat = paymentDetails.amountMsat == null
        ? 0
        : cubit.milliSatoshisToSatoshis(paymentDetails.amountMsat!);
    return Text(
      '$type: $amountSat sats',
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(PaymentDetails paymentDetails) {
    return Text(
      'Status: ${paymentDetails.status.name}',
    );
  }
}
