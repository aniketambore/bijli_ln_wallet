import 'dart:async';

import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeState> {
  HomeScreenCubit({
    required this.walletRepository,
  }) : super(const HomeInProgress()) {
    _fetchWalletInformation();
  }

  final WalletRepository walletRepository;
  late final StreamSubscription _walletInfoSubscription;

  Future<void> _fetchWalletInformation() async {
    try {
      _walletInfoSubscription = walletRepository.getWallet().listen((wallet) {
        emit(HomeSuccess(
          walletInfo: wallet,
          syncStatus: SyncStatus.success,
        ));
      });
    } catch (e) {
      emit(const HomeFailure());
    }
  }

  Future<void> refetch() async {
    emit(
      const HomeInProgress(),
    );

    await _fetchWalletInformation();
  }

  Future<void> refresh() async {
    final lastState = state;
    if (lastState is HomeSuccess) {
      emit(
        HomeSuccess(
          walletInfo: lastState.walletInfo,
          syncStatus: SyncStatus.inProgress,
        ),
      );
      await walletRepository.refreshWallet();
    }
  }

  Future<void> createInvoice({
    required int amountSat,
    String? description,
  }) async {
    final lastState = state;
    if (lastState is HomeSuccess) {
      final invoice = await walletRepository.createInvoice(
        amountSat: amountSat,
        description: description,
      );

      final newState = lastState.copyWith(
        walletInfo: lastState.walletInfo.copyWith(
          bolt11Invoice: invoice,
        ),
      );

      emit(newState);
    }
  }

  double satoshisToBitcoin(int satoshis) =>
      walletRepository.satoshisToBitcoin(satoshis);

  int bitcoinToSatoshis(double bitcoin) =>
      walletRepository.bitcoinToSatoshis(bitcoin);

  int milliSatoshisToSatoshis(int milliSatoshis) =>
      walletRepository.milliSatoshisToSatoshis(milliSatoshis);

  Future<void> closePaymentChannel({
    required ChannelId channelId,
    required PublicKey nodeId,
  }) async {
    await walletRepository.closePaymentChannel(
      channelId: channelId,
      nodeId: nodeId,
    );
    await walletRepository.refreshWallet();
  }

  @override
  Future<void> close() {
    _walletInfoSubscription.cancel();
    return super.close();
  }
}
