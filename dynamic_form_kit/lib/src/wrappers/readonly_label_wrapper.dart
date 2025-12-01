// lib/presentation/widgets/dynamic_form/wrappers/readonly_label_wrapper.dart

import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_readonly_label.dart';

class ReadOnlyLabelWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const ReadOnlyLabelWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String key = field['key'] ?? '';
    final String label = field['label'] ?? '';
    final config = field['config'] as Map<String, dynamic>? ?? {};
    final text = config['text'] as Map<String, dynamic>? ?? {};
    final style = config['style'] as Map<String, dynamic>? ?? {};

    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);
    final Color valueColor =
        StyleParser.parseColor(style['valueColor'], Colors.black);

    // reactive: prefer manager value
    final String value =
        manager.getValue(key)?.toString() ?? text['value']?.toString() ?? '';

    return VgotecReadOnlyLabel(
      label: label,
      value: value,
      labelColor: labelColor,
      valueColor: valueColor,
    );
  }
}
