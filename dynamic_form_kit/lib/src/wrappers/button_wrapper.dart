// lib/presentation/widgets/dynamic_form/wrappers/button_wrapper.dart

import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_button.dart';
import 'package:flutter/material.dart';
// Make sure this import path is correct for your package structure

class ButtonWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  // No 'onSubmit' callback is needed, making this widget decoupled.
  const ButtonWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse all config
    final String label = field['label'] ?? 'Button';
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};
    final placement = config['placement'] as Map<String, dynamic>? ?? {};
    final action = field['action'] as Map<String, dynamic>? ?? {};

    // Parse styles
    final Color backgroundColor =
        StyleParser.parseColor(style['backgroundColor'], Colors.blue);
    final Color textColor =
        StyleParser.parseColor(style['textColor'], Colors.white);
    final double fontSize = StyleParser.parseDouble(style['fontSize'], 16.0);
    final double width = StyleParser.parseDouble(placement['width'], 150.0);
    final double height = StyleParser.parseDouble(placement['height'], 50.0);

    // --- Action Logic ---
    VoidCallback? onPressed;
    // ... inside your build method
    if (action != null) {
      final String actionType = action['type'] ?? '';

      final Map<String, dynamic> payload =
          action['payload'] as Map<String, dynamic>? ?? {};
      debugPrint(
          "ButtonWrapper: Dispatching actionType='$actionType', payload='$payload'");

      // ⭐️ FIX: Dispatch the actionType AND the payload
      // This now works for 'submit', 'add_new', or any other action.
      onPressed = () => manager.dispatchAction(actionType, payload: payload);
    } else {
      // No action defined, button will be disabled or do nothing
      onPressed = null;
    }
    // ...
    // ... you could add "navigate", "validate", etc. here
    // --- End Action Logic ---

    // Return your VgotecButton
    return VgotecButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      width: width,
      height: height,
    );
  }
}
