import 'package:bijli_ln_wallet/routing_table.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const BijliBitcoinLNWallet());
}

class BijliBitcoinLNWallet extends StatefulWidget {
  const BijliBitcoinLNWallet({super.key});

  @override
  State<BijliBitcoinLNWallet> createState() => _BijliBitcoinLNWalletState();
}

class _BijliBitcoinLNWalletState extends State<BijliBitcoinLNWallet> {
  final _lightTheme = LightBitcoinThemeData();
  final _darkTheme = DarkBitcoinThemeData();
  final _walletRepository = WalletRepository();

  late final dynamic _routerDelegate = RoutemasterDelegate(
    routesBuilder: (context) {
      return RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          walletRepository: _walletRepository,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return BitcoinTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: MaterialApp.router(
        title: 'Bijli Bitcoin Lighting Wallet',
        theme: _lightTheme.materialThemeData,
        darkTheme: _darkTheme.materialThemeData,
        themeMode: ThemeMode.light,
        routerDelegate: _routerDelegate,
        routeInformationParser: const RoutemasterParser(),
      ),
    );
  }
}
