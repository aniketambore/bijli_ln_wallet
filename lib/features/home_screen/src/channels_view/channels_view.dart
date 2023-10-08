// ignore_for_file: use_build_context_synchronously

import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_screen_cubit.dart';

typedef OnCloseSuccess = Function(
  String title,
  String message,
  BuildContext context,
);

class ChannelsView extends StatelessWidget {
  const ChannelsView({
    super.key,
    required this.walletInfo,
    required this.onCloseSuccess,
  });
  final Wallet walletInfo;
  final OnCloseSuccess onCloseSuccess;

  @override
  Widget build(BuildContext context) {
    return walletInfo.paymentChannelsList.isEmpty
        ? const Center(
            child: BitcoinText(
              'No Open Channels',
              textAlign: TextAlign.start,
              fontWeight: FontWeight.w500,
              fontSize: FontSize.mediumLarge,
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(vertical: Spacing.mediumLarge),
            child: ChannelListWidget(
              channels: walletInfo.paymentChannelsList,
              onCloseSuccess: onCloseSuccess,
            ),
          );
  }
}

class ChannelListWidget extends StatefulWidget {
  const ChannelListWidget({
    super.key,
    required this.channels,
    required this.onCloseSuccess,
  });
  final List<ChannelDetails> channels;
  final OnCloseSuccess onCloseSuccess;

  @override
  State<ChannelListWidget> createState() => _ChannelListWidgetState();
}

class _ChannelListWidgetState extends State<ChannelListWidget> {
  bool isChannelClosing = false;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(
        height: Spacing.medium,
      ),
      itemCount: widget.channels.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) => channelListItem(index, context),
    );
  }

  ListTile channelListItem(int index, BuildContext context) {
    final channel = widget.channels[index];
    final isReady = channel.isUsable && channel.isChannelReady;
    final channelId = channel.channelId.internal
        .map((e) => e.toRadixString(16))
        .toList()
        .join()
        .toString();
    var borderRadius = const BorderRadius.all(Radius.circular(12));
    return ListTile(
      tileColor: BitcoinColors.neutral3,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      contentPadding: const EdgeInsets.all(Spacing.small),
      leading: Column(
        children: [
          Icon(
            isReady ? Icons.check_circle_outline : Icons.access_time_outlined,
          ),
          const SizedBox(height: Spacing.xSmall),
          BitcoinText(
            '${channel.confirmations} / ${channel.confirmationsRequired!}',
            overflow: TextOverflow.clip,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: BitcoinColors.neutral8,
          )
        ],
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: BitcoinText(
          channelId,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.start,
          color: BitcoinColors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 4.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoxRow(
                  title: "Capacity",
                  value: '${channel.channelValueSats}',
                  color: BitcoinColors.blue,
                ),
                BoxRow(
                  title: "Local Balance",
                  value: '${channel.balanceMsat / 1000}',
                  color: BitcoinColors.green,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BoxRow(
                  title: "Inbound",
                  value: '${channel.inboundCapacityMsat / 1000}',
                  color: BitcoinColors.green,
                ),
                BoxRow(
                  title: "     Outbound",
                  value: '${channel.outboundCapacityMsat / 1000}',
                  color: BitcoinColors.red,
                )
              ],
            ),
            SmallButton(
              text: "CLOSE",
              callback: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _ChannelCloseConfirmationDialog(
                        onCloseConfirmed: closeChannel(channel, channelId),
                        onCloseSuccess: widget.onCloseSuccess,
                        channelId: channelId,
                      );
                    });
              },
              disabled: !isReady,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> closeChannel(
    ChannelDetails channel,
    String channelId,
  ) async {
    final cubit = context.read<HomeScreenCubit>();
    try {
      await cubit.closePaymentChannel(
        channelId: channel.channelId,
        nodeId: channel.counterpartyNodeId,
      );
    } catch (e) {
      BijliFlushbar.showFlushbar(
        context,
        message: e.toString(),
      );
    }
  }
}

class _ChannelCloseConfirmationDialog extends StatefulWidget {
  const _ChannelCloseConfirmationDialog({
    required this.onCloseConfirmed,
    required this.onCloseSuccess,
    required this.channelId,
  });
  final Future<void> onCloseConfirmed;
  final OnCloseSuccess onCloseSuccess;
  final String channelId;

  @override
  State<_ChannelCloseConfirmationDialog> createState() =>
      _ChannelCloseConfirmationDialogState();
}

class _ChannelCloseConfirmationDialogState
    extends State<_ChannelCloseConfirmationDialog> {
  bool _isChannelClosing = false;

  Future<void> _onSubmit() async {
    setState(() => _isChannelClosing = true);
    await widget.onCloseConfirmed.then((value) => Navigator.pop(context));

    widget.onCloseSuccess(
      'Closed Successfully',
      'The channel with id: ${widget.channelId} is closed successfully.',
      context,
    );
    setState(() => _isChannelClosing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure you want to close this channel?'),
      actions: [
        _isChannelClosing
            ? const Center(child: CircularProgressIndicator())
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("NO"),
                  ),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text("YES"),
                  ),
                ],
              ),
      ],
    );
  }
}
