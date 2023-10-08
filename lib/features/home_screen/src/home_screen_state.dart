part of 'home_screen_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInProgress extends HomeState {
  const HomeInProgress();

  @override
  List<Object?> get props => [];
}

class HomeSuccess extends HomeState {
  const HomeSuccess({
    required this.walletInfo,
    this.syncStatus = SyncStatus.idle,
  });

  final Wallet walletInfo;
  final SyncStatus syncStatus;

  HomeSuccess copyWith({
    Wallet? walletInfo,
    SyncStatus? syncStatus,
  }) {
    return HomeSuccess(
      walletInfo: walletInfo ?? this.walletInfo,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        walletInfo,
        syncStatus,
      ];
}

class HomeFailure extends HomeState {
  const HomeFailure();

  @override
  List<Object?> get props => [];
}

enum SyncStatus {
  idle,
  inProgress,
  success,
  error,
}
