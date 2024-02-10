import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:bitcoin_icons/bitcoin_icons.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'receive_view/receive_view.dart';
import 'channels_view/channels_view.dart';
import 'payments_view/payments_view.dart';
import 'home_widgets/home_widgets.dart';

import 'home_screen_cubit.dart';

typedef OnSuccess = Function(
  String title,
  String message,
  BuildContext context,
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.walletRepository,
    required this.onOpenChannelTap,
    required this.onSendOffChainTap,
    required this.onSendOnChainTap,
    required this.onWalletInfoTap,
    required this.onSuccessPush,
  });
  final WalletRepository walletRepository;
  final VoidCallback onOpenChannelTap;
  final VoidCallback onSendOffChainTap;
  final VoidCallback onSendOnChainTap;
  final VoidCallback onWalletInfoTap;
  final OnSuccess onSuccessPush;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeScreenCubit(walletRepository: walletRepository),
      child: _HomeScreenView(
        onOpenChannelTap: onOpenChannelTap,
        onSendOffChainTap: onSendOffChainTap,
        onSendOnChainTap: onSendOnChainTap,
        onWalletInfoTap: onWalletInfoTap,
        onSuccessPush: onSuccessPush,
      ),
    );
  }
}

class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView({
    required this.onOpenChannelTap,
    required this.onSendOffChainTap,
    required this.onSendOnChainTap,
    required this.onWalletInfoTap,
    required this.onSuccessPush,
  });
  final VoidCallback onOpenChannelTap;
  final VoidCallback onSendOffChainTap;
  final VoidCallback onSendOnChainTap;
  final VoidCallback onWalletInfoTap;
  final OnSuccess onSuccessPush;

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  static const int channelsTabIndex = 2;
  static const int paymentsTabIndex = 1;

  late TabController _tabController;
  Animation<double>? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _tabController = TabController(length: 3, vsync: this);

    // Add a listener to the TabController to update the currentTabIndex when the tab changes.
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: HomeAppBar(onWalletInfoTap: widget.onWalletInfoTap),
        ),
        body: BlocConsumer<HomeScreenCubit, HomeState>(
          listenWhen: (oldState, newState) =>
              oldState is HomeSuccess && newState is HomeSuccess,
          listener: (context, state) {},
          builder: (context, state) {
            return state is HomeSuccess
                ? _HomeSuccessContent(
                    tabController: _tabController,
                    walletInfo: state.walletInfo,
                    onSuccessPush: widget.onSuccessPush,
                  )
                : state is HomeFailure
                    ? ExceptionIndicator(
                        onTryAgain: () {
                          final cubit = context.read<HomeScreenCubit>();
                          cubit.refetch();
                        },
                      )
                    : const SyncingView();
          },
        ),
        floatingActionButton: (_currentTabIndex == channelsTabIndex)
            ? OpenChannelFAB(
                animation: _animation,
                animationController: _animationController,
                onOpenChannelTap: widget.onOpenChannelTap,
              )
            : (_currentTabIndex == paymentsTabIndex)
                ? MakePaymentFAB(
                    animation: _animation,
                    animationController: _animationController,
                    onSendOffChainTap: widget.onSendOffChainTap,
                    onSendOnChainTap: widget.onSendOnChainTap,
                  )
                : null,
      ),
    );
  }
}

class _HomeSuccessContent extends StatelessWidget {
  const _HomeSuccessContent({
    required this.tabController,
    required this.walletInfo,
    required this.onSuccessPush,
  });
  final TabController tabController;
  final Wallet walletInfo;
  final OnSuccess onSuccessPush;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const WalletBalanceView(),
          const SizedBox(height: 10),
          TabBar(
            labelColor: BitcoinColors.black,
            controller: tabController,
            tabs: const [
              Tab(
                child: Row(
                  children: [
                    Icon(BitcoinIcons.receive),
                    SizedBox(width: 2),
                    Text('Receive'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(BitcoinIcons.flip_vertical),
                    SizedBox(width: 2),
                    Text('Payments'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(BitcoinIcons.channels),
                    SizedBox(width: 2),
                    Text('Channels'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ReceiveView(walletInfo: walletInfo),
                Payments(paymentsList: walletInfo.paymentsList),
                ChannelsView(
                  walletInfo: walletInfo,
                  onCloseSuccess: onSuccessPush,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
