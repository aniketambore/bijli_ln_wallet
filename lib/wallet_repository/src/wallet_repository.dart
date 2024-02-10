import 'dart:io';

import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:path_provider/path_provider.dart';
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:rxdart/rxdart.dart';

import 'wallet_secure_storage.dart';

class WalletRepository {
  late Logger logger;
  late File file;
  static const LDK_NODE_DIR = "LDK_NODE";
  static const esploraURL = "https://mempool.space/testnet/api";
  static const network = ldk.Network.testnet;
  late ldk.Node ldkNode;
  final WalletSecureStorage _secureStorage;
  final BehaviorSubject<Wallet> _walletSubject = BehaviorSubject();

  WalletRepository({
    @visibleForTesting WalletSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const WalletSecureStorage() {
    _getDirectoryForLogRecord().whenComplete(() {
      FileOutput fileOutput = FileOutput(file: file);
      ConsoleOutput consoleOutput = ConsoleOutput();
      List<LogOutput> multiOutput = [fileOutput, consoleOutput];
      logger = Logger(
        filter: DevelopmentFilter(),
        printer: PrettyPrinter(
          colors: true,
          printTime: true,
        ),
        output: MultiOutput(multiOutput),
      );
    });
  }

  Future<void> _getDirectoryForLogRecord() async {
    final Directory? directory = await getExternalStorageDirectory();
    file = File('${directory?.path}/satoshi.txt');
    print('[WalletRepository] Log Path: ${directory?.path}/satoshi.txt');
  }

  String _generateMnemonic() {
    logger.d('[WalletRepository] Generating mnemonic...');
    final mnemonic = bip39.generateMnemonic();
    logger.i('[WalletRepository] Mnemonic: $mnemonic');
    return mnemonic;
  }

  Future<String?> getWalletMnemonic() {
    return _secureStorage.getWalletMnemonic();
  }

  Future<String> createOrRecoverWallet({String? recoveryMnemonic}) async {
    logger.d('[WalletRepository] Creating wallet...');
    final mnemonic = recoveryMnemonic ?? _generateMnemonic();
    final directory = await getApplicationDocumentsDirectory();
    final storagePath = "${directory.path}/$LDK_NODE_DIR";
    logger.i('[WalletRepository] Storage Path: $storagePath');

    const esploraUrl = esploraURL;
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(internal: mnemonic))
        .setNetwork(network)
        .setStorageDirPath(storagePath)
        .setEsploraServer(esploraServerUrl: esploraUrl);
    ldkNode = await builder.build();
    await ldkNode.start();
    await _secureStorage.upsertWalletMnemonic(
      mnemonic: mnemonic,
    );
    return mnemonic;
  }

  Future<int> getOnChainBalance() async {
    logger.d('[WalletRepository] Geting On-Chain balance...');
    await ldkNode.syncWallets();
    final balance = await ldkNode.totalOnchainBalanceSats();
    logger.i('[WalletRepository] Balance: $balance sats');
    return balance;
  }

  Future<String> getOnChainAddress() async {
    logger.d('[WalletRepository] Geting On-Chain address...');
    final ldk.Address address = await ldkNode.newOnchainAddress();
    logger.i('[WalletRepository] Address: ${address.internal}');
    return address.internal;
  }

  Future<void> openPaymentChannel({
    required String nodeId,
    required String host,
    required int port,
    required int amountSat,
    int? pushToCounterpartySat,
  }) async {
    logger.d('[WalletRepository] Opening payment channel...');
    await ldkNode.connectOpenChannel(
      address: ldk.NetAddress.iPv4(
        addr: host,
        port: port,
      ),
      nodeId: ldk.PublicKey(internal: nodeId),
      channelAmountSats: amountSat,
      announceChannel: true,
      pushToCounterpartyMsat: (pushToCounterpartySat != null)
          ? satoshisToMilliSatoshis(pushToCounterpartySat)
          : 0,
    );
  }

  Future<List<ldk.ChannelDetails>> listPaymentChannels() async {
    logger.d('[WalletRepository] List payment channels...');
    final channels = await ldkNode.listChannels();
    logger.i("======Channels========");
    for (var e in channels) {
      logger.i("[+] isChannelReady: ${e.isChannelReady}");
      logger.i("[+] isUsable: ${e.isUsable}");
      logger.i("[+] confirmation: ${e.confirmations}");
      logger.i("[+] localBalanceMsat: ${e.outboundCapacityMsat}");
    }
    return channels;
  }

  Future<String> createInvoice({
    required int amountSat,
    String? description,
  }) async {
    logger.d('[WalletRepository] Creating BOLT11 invoice...');
    final invoice = await ldkNode.receivePayment(
      amountMsat: amountSat * 1000,
      description: (description != null && description.trim().isNotEmpty)
          ? description
          : 'Bijli Invoice',
      expirySecs: 10000,
    );
    logger.d('[WalletRepository] Invoice: ${invoice.internal}');
    return invoice.internal;
  }

  Future<String> createZeroSatInvoice({String? description}) async {
    logger.d('[WalletRepository] Creating BOLT11 zero sat invoice...');
    final invoice = await ldkNode.receiveVariableAmountPayment(
      description: (description != null && description.trim().isNotEmpty)
          ? description
          : 'Bijli Invoice',
      expirySecs: 10000,
    );
    logger.d('[WalletRepository] Zero sat invoice: ${invoice.internal}');
    return invoice.internal;
  }

  Future<ldk.PaymentStatus> sendOffChainPayment(
      {required String bolt11Invoice}) async {
    logger.d('[WalletRepository] Sending Off-Chain payment...');
    final paymentHash = await ldkNode.sendPayment(
      invoice: ldk.Invoice(
        internal: bolt11Invoice,
      ),
    );
    final result = await ldkNode.payment(paymentHash: paymentHash);
    return result!.status;
  }

  Future<void> closePaymentChannel({
    required ldk.ChannelId channelId,
    required ldk.PublicKey nodeId,
  }) async {
    logger.d('[WalletRepository] Closing payment channel...');
    await ldkNode.closeChannel(
      channelId: channelId,
      counterpartyNodeId: nodeId,
    );
  }

  Future<List<ldk.PaymentDetails>> listTransactions() async {
    logger.d('[WalletRepository] Retrieve all payments...');
    final paymentDetails = <ldk.PaymentDetails>[];
    final payments = await ldkNode.listPayments();
    logger.i("======Payments========");
    for (var e in payments) {
      if (e.status == ldk.PaymentStatus.succeeded) {
        logger.i("[+] Amount: ${e.amountMsat}");
        logger.i("[+] Direction: ${e.direction}");
        logger.i("[+] Status: ${e.status}");
        paymentDetails.add(e);
      }
    }
    return paymentDetails;
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

  Future<Wallet> _getWalletInformation() async {
    int inboundCapacitySats = 0;
    int outboundCapacitySats = 0;
    String? bolt11Invoice;
    int onChainBalanceSats = await getOnChainBalance();
    String onChainAddress = await getOnChainAddress();
    String nodeId = await getNodeId();
    List<ldk.ChannelDetails> paymentChannelsList = await listPaymentChannels();
    List<ldk.PeerDetails> peersList = await listPeers();
    List<ldk.PaymentDetails> paymentList = await listTransactions();

    for (var channel in paymentChannelsList) {
      inboundCapacitySats +=
          milliSatoshisToSatoshis(channel.inboundCapacityMsat);
      outboundCapacitySats +=
          milliSatoshisToSatoshis(channel.outboundCapacityMsat);
    }
    if (inboundCapacitySats != 0) {
      bolt11Invoice = await createZeroSatInvoice();
    }

    final walletInfo = Wallet(
      onChainBalanceSats: onChainBalanceSats,
      inboundCapacitySats: inboundCapacitySats,
      outboundCapacitySats: outboundCapacitySats,
      onChainAddress: onChainAddress,
      paymentChannelsList: paymentChannelsList,
      bolt11Invoice: bolt11Invoice,
      esploraUrl: esploraURL,
      network: network.name,
      nodeId: nodeId,
      peersList: peersList,
      paymentsList: paymentList,
    );

    return walletInfo;
  }

  Future<List<ldk.PeerDetails>> listPeers() async {
    final peers = await ldkNode.listPeers();
    return peers;
  }

  Future<String> getNodeId() async {
    final id = await ldkNode.nodeId();
    return id.internal;
  }

  Future<String> sendToOnchainAddress({
    required String address,
    required int amountSats,
  }) async {
    logger.d('[WalletRepository] Sending On-Chain payment...');
    final addr = ldk.Address(internal: address);
    final txid = await ldkNode.sendToOnchainAddress(
      address: addr,
      amountSats: amountSats,
    );
    logger.i('[WalletRepository] Send On-Chain Txid: ${txid.internal}');
    return txid.internal;
  }

  Future<void> sendSpontaneousPayment({
    required int amountMsat,
    required String nodeId,
  }) async {
    final id = ldk.PublicKey(internal: nodeId);
    await ldkNode.sendSpontaneousPayment(
      amountMsat: amountMsat,
      nodeId: id,
    );
  }
}
