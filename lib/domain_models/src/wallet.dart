import 'package:equatable/equatable.dart';
import 'package:ldk_node/ldk_node.dart';

class Wallet extends Equatable {
  const Wallet({
    required this.onChainBalanceSats,
    required this.inboundCapacitySats,
    required this.outboundCapacitySats,
    required this.onChainAddress,
    required this.paymentChannelsList,
    this.bolt11Invoice,
    required this.esploraUrl,
    required this.network,
    required this.nodeId,
    required this.peersList,
    required this.paymentsList,
  });

  final int onChainBalanceSats;
  final int inboundCapacitySats;
  final int outboundCapacitySats;
  final String onChainAddress;
  final String? bolt11Invoice;
  final List<ChannelDetails> paymentChannelsList;
  final String esploraUrl;
  final String network;
  final String nodeId;
  final List<PeerDetails> peersList;
  final List<PaymentDetails> paymentsList;

  Wallet copyWith({
    int? onChainBalanceSats,
    int? inboundCapacitySats,
    int? outboundCapacitySats,
    String? onChainAddress,
    String? bolt11Invoice,
    List<ChannelDetails>? paymentChannelsList,
    String? esploraUrl,
    String? network,
    String? nodeId,
    List<PeerDetails>? peersList,
    List<PaymentDetails>? paymentsList,
  }) {
    return Wallet(
      onChainBalanceSats: onChainBalanceSats ?? this.onChainBalanceSats,
      inboundCapacitySats: inboundCapacitySats ?? this.inboundCapacitySats,
      outboundCapacitySats: outboundCapacitySats ?? this.outboundCapacitySats,
      onChainAddress: onChainAddress ?? this.onChainAddress,
      bolt11Invoice: bolt11Invoice ?? this.bolt11Invoice,
      paymentChannelsList: paymentChannelsList ?? this.paymentChannelsList,
      esploraUrl: esploraUrl ?? this.esploraUrl,
      network: network ?? this.network,
      nodeId: nodeId ?? this.nodeId,
      peersList: peersList ?? this.peersList,
      paymentsList: paymentsList ?? this.paymentsList,
    );
  }

  @override
  List<Object?> get props => [
        onChainBalanceSats,
        inboundCapacitySats,
        outboundCapacitySats,
        onChainAddress,
        bolt11Invoice,
        paymentChannelsList,
        esploraUrl,
        network,
        nodeId,
        peersList,
        paymentsList,
      ];
}
