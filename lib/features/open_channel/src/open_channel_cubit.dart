import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'open_channel_state.dart';

class OpenChannelCubit extends Cubit<OpenChannelState> {
  OpenChannelCubit({
    required this.walletRepository,
  }) : super(const OpenChannelState());

  final WalletRepository walletRepository;

  Future<void> onSubmit({
    required String nodeId,
    required String host,
    required int port,
    required int amountSat,
    int? pushToCounterpartySat,
  }) async {
    final newState =
        state.copyWith(submissionStatus: SubmissionStatus.inProgress);
    emit(newState);

    try {
      await walletRepository.openPaymentChannel(
        nodeId: nodeId,
        host: host,
        port: port,
        amountSat: amountSat,
        pushToCounterpartySat: pushToCounterpartySat,
      );
      await walletRepository.refreshWallet();
      final newState =
          state.copyWith(submissionStatus: SubmissionStatus.success);
      emit(newState);
    } catch (e) {
      debugPrint('[ERROR ON OPENCHANNEL CUBIT] $e');
      final newState = state.copyWith(
        submissionStatus: SubmissionStatus.genericError,
      );
      emit(newState);
    }
  }
}
