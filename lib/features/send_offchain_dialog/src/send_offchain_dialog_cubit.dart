import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'send_offchain_dialog_state.dart';

class SendOffChainDialogCubit extends Cubit<SendOffChainDialogState> {
  SendOffChainDialogCubit({
    required this.walletRepository,
  }) : super(const SendOffChainDialogState());

  final WalletRepository walletRepository;

  Future<void> onSubmit(String bolt11) async {
    final newState = state.copyWith(
      submissionStatus: SubmissionStatus.inProgress,
    );
    emit(newState);

    try {
      await walletRepository.sendOffChainPayment(bolt11Invoice: bolt11);
      await walletRepository.refreshWallet();
      final newState = state.copyWith(
        submissionStatus: SubmissionStatus.success,
      );
      emit(newState);
    } catch (e) {
      final newState = state.copyWith(
        submissionStatus: SubmissionStatus.sendPaymentError,
      );
      emit(newState);
    }
  }
}
