part of 'send_offchain_dialog_cubit.dart';

class SendOffChainDialogState extends Equatable {
  const SendOffChainDialogState({
    this.submissionStatus = SubmissionStatus.idle,
  });

  final SubmissionStatus submissionStatus;

  SendOffChainDialogState copyWith({
    SubmissionStatus? submissionStatus,
  }) {
    return SendOffChainDialogState(
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [
        submissionStatus,
      ];
}

enum SubmissionStatus {
  idle,
  inProgress,
  success,
  genericError,
  sendPaymentError,
}
