part of 'open_channel_cubit.dart';

class OpenChannelState extends Equatable {
  const OpenChannelState({
    this.submissionStatus = SubmissionStatus.idle,
  });

  final SubmissionStatus submissionStatus;

  OpenChannelState copyWith({
    SubmissionStatus? submissionStatus,
  }) {
    return OpenChannelState(
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
}
