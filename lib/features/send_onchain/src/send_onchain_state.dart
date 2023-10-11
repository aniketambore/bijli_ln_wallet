part of 'send_onchain_cubit.dart';

class SendOnChainState extends Equatable {
  const SendOnChainState({
    this.txId,
    this.submissionStatus = SubmissionStatus.idle,
  });

  final String? txId;
  final SubmissionStatus submissionStatus;

  SendOnChainState copyWith({
    String? txId,
    SubmissionStatus? submissionStatus,
  }) {
    return SendOnChainState(
      txId: txId ?? this.txId,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [
        txId,
        submissionStatus,
      ];
}

enum SubmissionStatus {
  idle,
  inProgress,
  success,
  genericError,
}
