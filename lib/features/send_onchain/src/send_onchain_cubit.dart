import 'package:bijli_ln_wallet/wallet_repository/src/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'send_onchain_state.dart';

class SendOnChainCubit extends Cubit<SendOnChainState> {
  SendOnChainCubit({required this.walletRepository})
      : super(
          const SendOnChainState(),
        );

  final WalletRepository walletRepository;

  Future<void> onSubmit(
      {required String address, required int amountSats}) async {
    final newState =
        state.copyWith(submissionStatus: SubmissionStatus.inProgress);
    emit(newState);

    try {
      final txid = await walletRepository.sendToOnchainAddress(
        address: address,
        amountSats: amountSats,
      );
      await walletRepository.refreshWallet();
      final newState = state.copyWith(
        txId: txid,
        submissionStatus: SubmissionStatus.success,
      );
      emit(newState);
    } catch (e) {
      debugPrint('[ERROR ON SENDONCHAIN CUBIT] $e');
      final newState = state.copyWith(
        submissionStatus: SubmissionStatus.genericError,
      );
      emit(newState);
    }
  }
}
