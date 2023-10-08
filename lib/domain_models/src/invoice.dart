import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  const Invoice({
    required this.bolt11,
    required this.paymentHash,
    this.description,
    required this.amountSat,
  });

  final String bolt11;
  final String paymentHash;
  final String? description;
  final int amountSat;

  @override
  List<Object?> get props => [
        bolt11,
        paymentHash,
        description,
        amountSat,
      ];

  @override
  String toString() {
    return '{bolt11: $bolt11, paymentHash: $paymentHash, description: $description, amountSat: $amountSat}';
  }
}
