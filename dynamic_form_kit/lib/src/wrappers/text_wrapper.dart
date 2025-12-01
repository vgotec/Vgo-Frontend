import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_text_field.dart';
import 'package:flutter/material.dart';

class TextWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const TextWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  _TextWrapperState createState() => _TextWrapperState();
}

class _TextWrapperState extends State<TextWrapper> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final key = widget.field['key'];
    _controller = widget.manager.registerTextField(key);

    final dynamic defaultValue = widget.field['defaultValue'];

    // 1️⃣ EDIT MODE
    final existing = widget.manager.getValue(key);

    if (existing != null && existing.toString().isNotEmpty) {
      _controller.text = existing.toString();
      return;
    }

    // 2️⃣ CREATE MODE → apply default
    if (defaultValue != null) {
      final parsed = _parseDefault(defaultValue);
      _controller.text = parsed;
      widget.manager.setFieldValue(key, parsed);
    }
  }

  String _parseDefault(dynamic value) {
    if (value == "today") {
      return DateTime.now().toIso8601String().split("T").first;
    }
    if (value == "now") {
      return DateTime.now().toIso8601String();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.field['config'] ?? {};
    final behavior = config['behavior'] ?? {};
    final text = config['text'] ?? {};
    final style = config['style'] ?? {};
    final placement = config['placement'] ?? {};

    final label = widget.field['label'] ?? "";
    final String placeholder = text['placeholder'] ?? "";
    final bool isRequired = behavior['required'] ?? false;
    final bool readOnly = behavior['readOnly'] ?? false;
    final int maxLines = placement['maxLines'] ?? 1;

    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);
    final Color borderColor =
        StyleParser.parseColor(style['borderColor'], Colors.grey.shade400);

    return VgotecTextField(
      label: label,
      placeholder: placeholder,
      controller: _controller,
      isRequired: isRequired,
      maxLines: maxLines,
      labelColor: labelColor,
      borderColor: borderColor,
      readOnly: readOnly,
    );
  }
}
