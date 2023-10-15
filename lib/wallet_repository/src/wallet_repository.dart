import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'wallet_secure_storage.dart';

// TODO: Add imports here

class WalletRepository {
  // TODO: Initialize variables here
  final WalletSecureStorage _secureStorage;
  final BehaviorSubject<Wallet> _walletSubject = BehaviorSubject();

  WalletRepository({
    @visibleForTesting WalletSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const WalletSecureStorage();

  // TODO: Implement method to generate a new mnemonic
  String _generateMnemonic() {
    return 'dummy_mnemonic';
  }

  // TODO: Implement method to create or recover a wallet
  Future<String> createOrRecoverWallet({String? recoveryMnemonic}) async {
    return Future.value('dummy_mnemonic'); // Dummy return value
  }

  // TODO: Implement method to retrieve wallet mnemonic from storage
  Future<String?> getWalletMnemonic() {
    return Future.value(null); // Dummy return value
  }

  // TODO: Implement method to retrieve Lightning node ID
  Future<String> getNodeId() async {
    return Future.value('dummy_node_id'); // Dummy return value
  }

  // TODO: Implement method to retrieve on-chain address
  Future<String> getOnChainAddress() async {
    return Future.value('dummy_address'); // Dummy return value
  }

  // TODO: Implement method to retrieve on-chain balance
  Future<int> getOnChainBalance() async {
    return Future.value(0); // Dummy return value
  }

  // TODO: Implement method to send funds to an on-chain address
  Future<String> sendToOnchainAddress({
    required String address,
    required int amountSats,
  }) async {
    return Future.value('dummy_txid'); // Dummy return value
  }

  // TODO: Implement method to open a Lightning payment channel
  Future<void> openPaymentChannel({
    required String nodeId,
    required String host,
    required int port,
    required int amountSat,
    int? pushToCounterpartySat,
  }) async {
    // Dummy implementation
  }

  // TODO: Implement method to list Lightning payment channels
  Future<List<dynamic>> listPaymentChannels() async {
    return Future.value([]); // Dummy return value
  }

  // TODO: Implement method to list Lightning peers
  Future<List<dynamic>> listPeers() async {
    return Future.value([]); // Dummy return value
  }

  // TODO: Implement method to list Lightning transactions
  Future<List<dynamic>> listTransactions() async {
    return Future.value([]); // Dummy return value
  }

  // TODO: Implement method to create a BOLT11 invoice
  Future<String> createInvoice({
    required int amountSat,
    String? description,
  }) async {
    return Future.value('dummy_invoice'); // Dummy return value
  }

  // TODO: Implement method to create a zero-sat BOLT11 invoice
  Future<String> createZeroSatInvoice({String? description}) async {
    return Future.value('dummy_invoice'); // Dummy return value
  }

  // TODO: Implement method to send an off-chain Lightning payment
  Future<dynamic> sendOffChainPayment({
    required String bolt11Invoice,
  }) async {
    // Dummy implementation
  }

  // TODO: Implement method to close a Lightning payment channel
  Future<void> closePaymentChannel({
    required dynamic channelId, // Replace with appropriate type
    required dynamic nodeId, // Replace with appropriate type
  }) async {
    // Dummy implementation
  }

  Stream<Wallet> getWallet() async* {
    if (!_walletSubject.hasValue) {
      final walletInfo = await _getWalletInformation();

      _walletSubject.add(walletInfo);
    }
    yield* _walletSubject.stream;
  }

  Future<void> refreshWallet() async {
    final walletInfo = await _getWalletInformation();
    _walletSubject.add(walletInfo);
  }

  // TODO: Implement method to retrieve wallet information
  Future<Wallet> _getWalletInformation() async {
    // TODO: Initialize variables to hold various wallet information
    // TODO: Retrieve our own node ID
    // TODO: Retrieve on-chain balance and address information
    // TODO: Retrieve lists of payment channels, peers, and payment details

    // TODO: Calculate inbound and outbound channel capacities

    // TODO: If there are inbound capacity, create a zero-satoshis invoice (BOLT11 format)

    // Dummy implementation
    return const Wallet(
      onChainBalanceSats: 0,
      inboundCapacitySats: 0,
      outboundCapacitySats: 0,
      onChainAddress: 'dummy_address',
      paymentChannelsList: [],
      bolt11Invoice: 'dummy_invoice',
      esploraUrl: 'dummy_esplora_url',
      network: 'testnet',
      nodeId: 'dummy_node_id',
      peersList: [],
      paymentsList: [],
    );
  }

  double satoshisToBitcoin(int satoshis) {
    return satoshis / 100000000.0;
  }

  int bitcoinToSatoshis(double bitcoin) {
    return (bitcoin * 100000000).round();
  }

  int satoshisToMilliSatoshis(int satoshis) {
    return satoshis * 1000;
  }

  int milliSatoshisToSatoshis(int milliSatoshis) {
    return milliSatoshis ~/ 1000;
  }

  Invoice decodeBolt11Invoice(String bolt11) {
    Bolt11PaymentRequest request = Bolt11PaymentRequest(bolt11);
    final invoice = Invoice(
      bolt11: request.paymentRequest,
      paymentHash: request.tags[0].data,
      amountSat: (request.amount.toDouble() * 100000000).toInt(),
      description: request.tags[1].data,
    );
    return invoice;
  }
}
