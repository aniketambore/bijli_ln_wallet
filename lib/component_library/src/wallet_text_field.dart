import 'package:bitcoin_ui_kit/bitcoin_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'themes/font_size.dart';

class WalletTextField extends StatelessWidget {
  const WalletTextField({
    super.key,
    required this.labelText,
    this.focusNode,
    this.autoCorrect,
    this.enabled,
    this.errorText,
    this.textInputAction,
    this.onChanged,
    this.keyboardType,
    this.obscureText,
    this.onEditingComplete,
    this.controller,
    this.suffixIcon,
    this.maxLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.validator,
  });

  final String labelText;
  final FocusNode? focusNode;
  final bool? autoCorrect;
  final bool? enabled;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final Function()? onEditingComplete;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText ?? false,
      style: const TextStyle(
        fontSize: FontSize.mediumLarge,
        fontWeight: FontWeight.w500,
        color: BitcoinColors.neutral8,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        // errorText: errorText,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: BitcoinColors.neutral1Dark,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: BitcoinColors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: textInputAction,
      autocorrect: autoCorrect ?? true,
      onEditingComplete: onEditingComplete,
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      validator: validator,
    );
  }
}
