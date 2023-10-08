import 'dart:math';

import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';

class SuccessIndicatorScreen extends StatefulWidget {
  const SuccessIndicatorScreen({
    super.key,
    this.title,
    this.message,
    required this.onOkayTap,
  });

  final String? title;
  final String? message;
  final VoidCallback onOkayTap;

  @override
  State<SuccessIndicatorScreen> createState() => _SuccessIndicatorScreenState();
}

class _SuccessIndicatorScreenState extends State<SuccessIndicatorScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xLarge,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const CircleWidget(
                      borderColor: BitcoinColors.black,
                      bgColor: BitcoinColors.greenDark,
                      size: 161,
                      iconData: Icons.check_outlined,
                      borderWidth: 4,
                    ),
                    const SizedBox(height: Spacing.xxLarge),
                    Text(
                      widget.title ?? 'Success',
                      style: const TextStyle(
                        fontSize: FontSize.xLarge,
                        fontWeight: FontWeight.w600,
                        color: BitcoinColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.medium),
                    Text(
                      widget.message ??
                          'Congratulations, your request has been successfully processed!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: FontSize.mediumLarge,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                        color: BitcoinColors.neutral8,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxLarge),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: BitcoinElevatedButton(
                        label: 'Okay',
                        onPressed: () => Navigator.pop(context),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2,
          gravity: 0.05,
          emissionFrequency: 0.05,
        ),
      ],
    );
  }
}
