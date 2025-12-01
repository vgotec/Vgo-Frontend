import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';
import 'package:dynamic_form_kit/src/widget_collection/vgotec_dropdown.dart';
import 'package:flutter/material.dart';

class DropdownWrapper extends StatefulWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const DropdownWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  _DropdownWrapperState createState() => _DropdownWrapperState();
}

class _DropdownWrapperState extends State<DropdownWrapper> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();

    final String key = widget.field['key'];
    final dynamic defaultValue = widget.field['defaultValue'];

    // 1️⃣ Existing manager value (EDIT MODE)
    final existing = widget.manager.getValue(key);

    if (existing != null) {
      _selectedValue = existing.toString();
    }
    // 2️⃣ Default value from JSON (CREATE MODE)
    else if (defaultValue != null) {
      _selectedValue = defaultValue.toString();
      widget.manager.setFieldValue(key, _selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String key = widget.field['key'];
    final String label = widget.field['label'] ?? '';

    final config = widget.field['config'] ?? {};
    final style = config['style'] ?? {};
    final text = config['text'] ?? {};
    final data = config['data'] ?? {};
    final behavior = config['behavior'] ?? {};

    final bool readOnly = behavior['readOnly'] == true;

    final String placeholder = text['placeholder'] ?? "Select option";
    final Color labelColor =
        StyleParser.parseColor(style['labelColor'], Colors.grey.shade700);

    // Prepare dropdown items
    final List<Map<String, String>> items = [];
    final List options = data['options'] ?? [];

    for (var opt in options) {
      if (opt is Map) {
        items.add({
          "label": opt['label'].toString(),
          "value": opt['value'].toString(),
        });
      } else {
        items.add({"label": opt.toString(), "value": opt.toString()});
      }
    }

    widget.manager.registerDropdownData(key, items);

    return IgnorePointer(
      ignoring: readOnly,
      child: Opacity(
        opacity: readOnly ? 0.6 : 1.0,
        child: VgotecDropdown(
          label: label,
          placeholder: placeholder,
          items: items,
          value: _selectedValue,
          readOnly: readOnly,
          labelColor: labelColor,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedValue = value);
              widget.manager.setFieldValue(key, value);
            }
          },
        ),
      ),
    );
  }
}
