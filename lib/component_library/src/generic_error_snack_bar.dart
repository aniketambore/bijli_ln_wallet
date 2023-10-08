import 'package:flutter/material.dart';

class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({Key? key})
      : super(
          key: key,
          content: const _GenericErrorSnackBarMessage(),
        );
}

class _GenericErrorSnackBarMessage extends StatelessWidget {
  const _GenericErrorSnackBarMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'There has been an error. Please, check your internet connection.',
    );
  }
}
