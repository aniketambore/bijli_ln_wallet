part of 'wallet_information_cubit.dart';

abstract class WalletInformationState extends Equatable {
  const WalletInformationState();
}

class WalletInformationProgress extends WalletInformationState {
  const WalletInformationProgress();

  @override
  List<Object?> get props => [];
}

class WalletInformationSuccess extends WalletInformationState {
  const WalletInformationSuccess({
    required this.mnemonic,
    required this.walletInfo,
    required this.syncStatus,
  });

  final List<String> mnemonic;
  final Wallet walletInfo;
  final SyncStatus syncStatus;

  @override
  List<Object?> get props => [
        mnemonic,
        walletInfo,
        syncStatus,
      ];
}

class WalletInformationFailure extends WalletInformationState {
  const WalletInformationFailure();

  @override
  List<Object?> get props => [];
}

enum SyncStatus {
  idle,
  inProgress,
  success,
  error,
}
