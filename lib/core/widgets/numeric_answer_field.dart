import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';
import '../constants/typography.dart';

/// A numeric (integer) answer field with a submit button, shared by the Math and
/// Tessellation activities. Accepts digits and '-' only; submitting a parseable
/// value calls [onSubmit] and clears the field.
class NumericAnswerField extends StatefulWidget {
  const NumericAnswerField({
    super.key,
    required this.onSubmit,
    this.hintText = 'Answer',
    this.submitLabel = 'Solve',
  });

  final void Function(int value) onSubmit;
  final String hintText;
  final String submitLabel;

  @override
  State<NumericAnswerField> createState() => _NumericAnswerFieldState();
}

class _NumericAnswerFieldState extends State<NumericAnswerField> {
  final _controller = TextEditingController();

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null) return;
    widget.onSubmit(value);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
            ],
            style: TaaevonTypography.mono.copyWith(fontSize: 18),
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: TaaevonColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TaaevonDimensions.radiusSm),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: TaaevonDimensions.sm),
        SizedBox(
          height: TaaevonDimensions.buttonHeight,
          child: ElevatedButton(
            onPressed: _submit,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}
