import 'package:bijli_ln_wallet/features/home_screen/home_screen.dart';
import 'package:bijli_ln_wallet/features/open_channel/open_channel.dart';
import 'package:bijli_ln_wallet/features/send_offchain/send_offchain.dart';
import 'package:bijli_ln_wallet/features/send_offchain_dialog/send_offchain_dialog.dart';
import 'package:bijli_ln_wallet/features/success_indicator/success_indicator.dart';
import 'package:bijli_ln_wallet/features/wallet_creation/wallet_creation.dart';
import 'package:bijli_ln_wallet/features/wallet_info/wallet_info.dart';
import 'package:bijli_ln_wallet/splash_screen.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required WalletRepository walletRepository,
}) {
  return {
    _PathConstants.splashPath: (_) {
      return MaterialPage(
        name: 'splash',
        child: SplashScreen(
          walletRepository: walletRepository,
          pushToCreateWallet: () {
            routerDelegate.replace(
              _PathConstants.createWalletPath,
            );
          },
          pushToHome: () {
            routerDelegate.replace(
              _PathConstants.homePath,
            );
          },
        ),
      );
    },
    _PathConstants.createWalletPath: (_) {
      return MaterialPage(
        name: 'create-wallet',
        child: WalletCreationScreen(
          walletRepository: walletRepository,
          onCreateWalletSuccess: () {
            routerDelegate.replace(
              _PathConstants.homePath,
            );
          },
          onRecoverWalletTap: () {
            // routerDelegate.push(
            //   _PathConstants.recoverWalletPath,
            // );
          },
        ),
      );
    },
    _PathConstants.homePath: (_) {
      return MaterialPage(
        name: 'home',
        child: HomeScreen(
            walletRepository: walletRepository,
            onOpenChannelTap: () {
              routerDelegate.push(_PathConstants.openChannelPath);
            },
            onSendOffChainTap: () {
              routerDelegate.push(_PathConstants.sendOffChainPath);
            },
            onWalletInfoTap: () {
              routerDelegate.push(_PathConstants.walletInfoPath);
            },
            onSuccessPush: (title, message, context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessIndicatorScreen(
                    title: title,
                    message: message,
                    onOkayTap: () {
                      routerDelegate.pop();
                    },
                  ),
                ),
              );
            }),
      );
    },
    _PathConstants.openChannelPath: (_) {
      return MaterialPage(
        name: 'open-channel',
        child: OpenChannelScreen(
          walletRepository: walletRepository,
          onChannelOpenSuccess: (title, message, context) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SuccessIndicatorScreen(
                  title: title,
                  message: message,
                  onOkayTap: () {
                    routerDelegate.pop();
                  },
                ),
              ),
            );
          },
        ),
      );
    },
    _PathConstants.sendOffChainPath: (_) {
      return MaterialPage(
        name: 'send-offchain',
        child: SendOffChainScreen(
          walletRepository: walletRepository,
          onInvoiceParsedSuccess: (invoiceInfo) {
            return SendOffChainDialog(
              invoice: invoiceInfo,
              walletRepository: walletRepository,
              onSendSuccess: (title, message, context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuccessIndicatorScreen(
                      title: title,
                      message: message,
                      onOkayTap: () {
                        routerDelegate.pop();
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
    _PathConstants.walletInfoPath: (_) {
      return MaterialPage(
        name: 'wallet-info',
        child: WalletInformationScreen(
          walletRepository: walletRepository,
        ),
      );
    }
  };
}

class _PathConstants {
  const _PathConstants._();

  static String get splashPath => '/';
  static String get createWalletPath => '/create-wallet';
  static String get recoverWalletPath => '${createWalletPath}recover';

  static String get homePath => '/home';

  static String get openChannelPath => '$homePath/open-channel';

  static String get sendOffChainPath => '$homePath/send-offchain';

  static String get walletInfoPath => '$homePath/wallet-info';
}
