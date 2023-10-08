import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WalletSecureStorage {
  static const _mnemonicKey = 'wallet-mnemonic';

  const WalletSecureStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<void> upsertWalletMnemonic({
    required String mnemonic,
  }) =>
      Future.wait([
        _secureStorage.write(
          key: _mnemonicKey,
          value: mnemonic,
        ),
      ]);

  Future<void> deleteWalletMnenomic() => Future.wait([
        _secureStorage.delete(
          key: _mnemonicKey,
        ),
      ]);

  Future<String?> getWalletMnemonic() => _secureStorage.read(
        key: _mnemonicKey,
      );
}
