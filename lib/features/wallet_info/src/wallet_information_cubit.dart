import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wallet_information_state.dart';

class WalletInformationCubit extends Cubit<WalletInformationState> {
  WalletInformationCubit({
    required this.walletRepository,
  }) : super(const WalletInformationProgress()) {
    _fetchWalletInformation();
  }
  final WalletRepository walletRepository;

  Future<void> _fetchWalletInformation() async {
    try {
      final mnemonic = await walletRepository.getWalletMnemonic();
      final mnemonicList = [for (var word in mnemonic!.split(' ')) word];
      final walletInfo = await walletRepository.getWallet().first;
      emit(
        WalletInformationSuccess(
          mnemonic: mnemonicList,
          walletInfo: walletInfo,
          syncStatus: SyncStatus.success,
        ),
      );
    } catch (e) {
      emit(
        const WalletInformationFailure(),
      );
    }
  }

  Future<void> refetch() async {
    emit(
      const WalletInformationProgress(),
    );

    _fetchWalletInformation();
  }
}
